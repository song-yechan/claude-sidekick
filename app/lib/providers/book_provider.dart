/// 책(도서) 상태 관리 Provider
///
/// 이 파일은 앱에서 책 데이터를 관리하는 모든 Provider를 포함합니다.
/// 사용자의 서재에 등록된 책 목록 조회, 검색, 추가, 삭제 기능을 제공합니다.
///
/// 주요 기능:
/// - 사용자별 책 목록 관리 (booksProvider)
/// - 알라딘 API를 통한 도서 검색 (bookSearchProvider)
/// - 카테고리별 책 필터링 (booksByCategoryProvider)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/review_service.dart';
import 'auth_provider.dart';

export '../models/book.dart' show BookSearchResult;

/// BookService 인스턴스를 제공하는 Provider
final bookServiceProvider = Provider<IBookService>((ref) => BookService());

/// ReviewService 인스턴스를 제공하는 Provider
final reviewServiceProvider = Provider<IReviewService>((ref) => ReviewService());

/// 현재 로그인한 사용자의 책 목록을 제공하는 Provider
///
/// authProvider를 구독하여 사용자 변경 시 자동으로 새로운 목록을 가져옵니다.
/// 로그인되지 않은 경우 빈 목록을 반환합니다.
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final authState = ref.watch(authProvider);
  final bookService = ref.watch(bookServiceProvider);

  print('📚 booksProvider - user: ${authState.user?.id}');

  // 로그인되지 않은 경우 빈 목록 반환
  if (authState.user == null) {
    print('📚 booksProvider - user is null, returning empty list');
    return [];
  }

  try {
    final books = await bookService.getBooks(authState.user!.id);
    print('📚 booksProvider - fetched ${books.length} books');
    return books;
  } catch (e) {
    print('📚 booksProvider - error: $e');
    rethrow;
  }
});

/// 특정 ID의 책을 조회하는 Family Provider
///
/// [bookId] 조회할 책의 고유 ID
/// booksProvider에서 캐시된 목록을 사용하므로 추가 API 호출 없이 동작합니다.
final bookProvider = Provider.family<Book?, String>((ref, bookId) {
  final booksAsync = ref.watch(booksProvider);
  return booksAsync.whenOrNull(
    data: (books) => books.where((b) => b.id == bookId).firstOrNull,
  );
});

/// 특정 카테고리에 속한 책 목록을 제공하는 Family Provider
///
/// [categoryId] 필터링할 카테고리의 고유 ID
/// 책은 여러 카테고리에 속할 수 있으므로 categoryIds에 포함 여부로 필터링합니다.
final booksByCategoryProvider =
    Provider.family<List<Book>, String>((ref, categoryId) {
  final booksAsync = ref.watch(booksProvider);
  return booksAsync.whenOrNull(
        data: (books) =>
            books.where((b) => b.categoryIds.contains(categoryId)).toList(),
      ) ??
      [];
});

/// 도서 검색 상태를 나타내는 불변 클래스
///
/// 알라딘 API를 통한 도서 검색의 현재 상태를 담습니다.
class BookSearchState {
  /// 검색 진행 중 여부
  final bool isLoading;

  /// 검색 결과 목록
  final List<BookSearchResult> results;

  /// 에러 메시지 (검색 실패 시)
  final String? error;

  const BookSearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  BookSearchState copyWith({
    bool? isLoading,
    List<BookSearchResult>? results,
    String? error,
  }) {
    return BookSearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }
}

/// 도서 검색 기능을 관리하는 StateNotifier
///
/// 알라딘 API를 통해 도서를 검색하고 결과를 상태로 관리합니다.
/// 검색어가 비어있으면 상태를 초기화합니다.
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  final IBookService _bookService;

  BookSearchNotifier(this._bookService) : super(const BookSearchState());

  /// 도서 검색을 수행합니다.
  ///
  /// [query] 검색할 키워드 (제목, 저자 등)
  /// 빈 검색어의 경우 상태를 초기화하고 종료합니다.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const BookSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _bookService.searchBooks(query);
      state = BookSearchState(results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 검색 상태를 초기화합니다.
  void clear() {
    state = const BookSearchState();
  }
}

/// 도서 검색 상태를 관리하는 Provider
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>((ref) {
  final bookService = ref.watch(bookServiceProvider);
  return BookSearchNotifier(bookService);
});

/// 새 책을 서재에 추가합니다.
///
/// [ref] Riverpod WidgetRef
/// [title] 책 제목 (필수)
/// [author] 저자 (필수)
/// [isbn] ISBN 번호
/// [publisher] 출판사
/// [publishDate] 출판일
/// [coverImage] 표지 이미지 URL
/// [description] 책 설명
/// [pageCount] 페이지 수
/// [categoryIds] 이 책이 속할 카테고리 ID 목록
///
/// 성공 시 생성된 Book 객체를 반환하고, 실패 시 null을 반환합니다.
/// 추가 후 booksProvider를 갱신하여 목록을 새로고침합니다.
Future<Book?> addBook(
  WidgetRef ref, {
  required String title,
  required String author,
  String? isbn,
  String? publisher,
  String? publishDate,
  String? coverImage,
  String? description,
  int? pageCount,
  List<String> categoryIds = const [],
}) async {
  final authState = ref.read(authProvider);
  final bookService = ref.read(bookServiceProvider);

  if (authState.user == null) {
    return null;
  }

  try {
    final book = await bookService.addBook(
      userId: authState.user!.id,
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      publishDate: publishDate,
      coverImage: coverImage,
      description: description,
      pageCount: pageCount,
      categoryIds: categoryIds,
    );

    // 책 목록 새로고침
    ref.invalidate(booksProvider);

    // 책 2권 이상 저장 시 인앱 리뷰 요청
    final reviewService = ref.read(reviewServiceProvider);
    final books = await bookService.getBooks(authState.user!.id);
    await reviewService.checkAndRequestReviewForBooks(books.length);

    return book;
  } catch (e) {
    return null;
  }
}

/// 서재에서 책을 삭제합니다.
///
/// [ref] Riverpod WidgetRef
/// [bookId] 삭제할 책의 고유 ID
///
/// 성공 시 true, 실패 시 false를 반환합니다.
/// 삭제 후 booksProvider를 갱신합니다.
Future<bool> deleteBook(WidgetRef ref, String bookId) async {
  final bookService = ref.read(bookServiceProvider);

  try {
    await bookService.deleteBook(bookId);
    ref.invalidate(booksProvider);
    return true;
  } catch (e) {
    return false;
  }
}

/// 중복 책이 있는지 확인합니다.
///
/// [ref] Riverpod WidgetRef
/// [isbn] ISBN (선택)
/// [title] 책 제목
/// [author] 저자
///
/// 중복 책이 있으면 해당 Book 객체를 반환하고, 없으면 null을 반환합니다.
Future<Book?> findDuplicateBook(
  WidgetRef ref, {
  String? isbn,
  required String title,
  required String author,
}) async {
  final authState = ref.read(authProvider);
  final bookService = ref.read(bookServiceProvider);

  if (authState.user == null) {
    return null;
  }

  try {
    return await bookService.findDuplicateBook(
      userId: authState.user!.id,
      isbn: isbn,
      title: title,
      author: author,
    );
  } catch (e) {
    return null;
  }
}

/// 책의 카테고리를 업데이트합니다.
///
/// [ref] Riverpod WidgetRef
/// [bookId] 업데이트할 책의 고유 ID
/// [categoryIds] 새로운 카테고리 ID 목록
///
/// 성공 시 true, 실패 시 false를 반환합니다.
Future<bool> updateBookCategories(
  WidgetRef ref,
  String bookId,
  List<String> categoryIds,
) async {
  final bookService = ref.read(bookServiceProvider);

  try {
    await bookService.updateBook(
      bookId: bookId,
      categoryIds: categoryIds,
    );
    ref.invalidate(booksProvider);
    return true;
  } catch (e) {
    return false;
  }
}
