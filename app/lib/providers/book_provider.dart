import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'auth_provider.dart';

export '../models/book.dart' show BookSearchResult;

/// BookService 프로바이더
final bookServiceProvider = Provider<BookService>((ref) => BookService());

/// 책 목록 프로바이더
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final authState = ref.watch(authProvider);
  final bookService = ref.watch(bookServiceProvider);

  if (authState.user == null) return [];

  return bookService.getBooks(authState.user!.id);
});

/// 특정 책 프로바이더
final bookProvider = Provider.family<Book?, String>((ref, bookId) {
  final booksAsync = ref.watch(booksProvider);
  return booksAsync.whenOrNull(
    data: (books) => books.where((b) => b.id == bookId).firstOrNull,
  );
});

/// 카테고리별 책 목록 프로바이더
final booksByCategoryProvider =
    Provider.family<List<Book>, String>((ref, categoryId) {
  final booksAsync = ref.watch(booksProvider);
  return booksAsync.whenOrNull(
        data: (books) =>
            books.where((b) => b.categoryIds.contains(categoryId)).toList(),
      ) ??
      [];
});

/// 도서 검색 상태
class BookSearchState {
  final bool isLoading;
  final List<BookSearchResult> results;
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

/// 도서 검색 Notifier
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  final BookService _bookService;

  BookSearchNotifier(this._bookService) : super(const BookSearchState());

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

  void clear() {
    state = const BookSearchState();
  }
}

/// 도서 검색 프로바이더
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>((ref) {
  final bookService = ref.watch(bookServiceProvider);
  return BookSearchNotifier(bookService);
});

/// 책 추가 함수
Future<Book?> addBook(
  WidgetRef ref, {
  required String title,
  required String author,
  String? isbn,
  String? publisher,
  String? publishDate,
  String? coverImage,
  String? description,
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
      categoryIds: categoryIds,
    );

    // 책 목록 새로고침
    ref.invalidate(booksProvider);

    return book;
  } catch (e) {
    return null;
  }
}

/// 책 삭제 함수
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
