/// Mock BookService
///
/// 테스트용 BookService 모킹 클래스입니다.
/// 실제 Supabase 호출 없이 테스트할 수 있도록 합니다.
library;

import 'package:bookscribe/models/book.dart';
import 'test_fixtures.dart';

/// BookService 인터페이스
///
/// 실제 BookService와 MockBookService가 공유하는 인터페이스입니다.
abstract class IBookService {
  Future<List<Book>> getBooks(String userId);
  Future<Book> addBook({
    required String userId,
    required String title,
    required String author,
    String? isbn,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    int? pageCount,
    List<String> categoryIds,
  });
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    List<String>? categoryIds,
  });
  Future<void> deleteBook(String bookId);
  Future<List<BookSearchResult>> searchBooks(String query);
}

/// Mock BookService
///
/// 테스트에서 사용할 BookService 모킹 구현체입니다.
class MockBookService implements IBookService {
  /// 내부 저장소 (메모리)
  final List<Book> _books = [];
  final List<BookSearchResult> _searchResults = [];
  /// 책 ID -> 사용자 ID 매핑 (DB에서는 user_id 컬럼으로 관리)
  final Map<String, String> _bookOwners = {};

  /// 에러 시뮬레이션용 플래그
  bool shouldThrowOnGetBooks = false;
  bool shouldThrowOnAddBook = false;
  bool shouldThrowOnUpdateBook = false;
  bool shouldThrowOnDeleteBook = false;
  bool shouldThrowOnSearch = false;

  /// 커스텀 에러 메시지
  String errorMessage = 'Mock error';

  /// 지연 시뮬레이션 (ms)
  int delayMs = 0;

  /// 초기화
  MockBookService() {
    reset();
  }

  /// 상태 초기화
  void reset() {
    _books.clear();
    _searchResults.clear();
    _bookOwners.clear();
    shouldThrowOnGetBooks = false;
    shouldThrowOnAddBook = false;
    shouldThrowOnUpdateBook = false;
    shouldThrowOnDeleteBook = false;
    shouldThrowOnSearch = false;
    errorMessage = 'Mock error';
    delayMs = 0;
  }

  /// 테스트용 책 추가 (사용자 지정)
  void seedBooks(List<Book> books, {String? userId}) {
    final ownerId = userId ?? TestUsers.userId1;
    for (final book in books) {
      _books.add(book);
      _bookOwners[book.id] = ownerId;
    }
  }

  /// 테스트용 검색 결과 설정
  void setSearchResults(List<BookSearchResult> results) {
    _searchResults.clear();
    _searchResults.addAll(results);
  }

  /// 현재 저장된 책 목록 반환 (테스트 검증용)
  List<Book> get books => List.unmodifiable(_books);

  Future<void> _simulateDelay() async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  @override
  Future<List<Book>> getBooks(String userId) async {
    await _simulateDelay();
    if (shouldThrowOnGetBooks) {
      throw Exception(errorMessage);
    }
    return _books.where((b) => _bookOwners[b.id] == userId).toList();
  }

  @override
  Future<Book> addBook({
    required String userId,
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
    await _simulateDelay();
    if (shouldThrowOnAddBook) {
      throw Exception(errorMessage);
    }

    final newBook = Book(
      id: 'mock-book-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      publishDate: publishDate,
      coverImage: coverImage,
      description: description,
      pageCount: pageCount,
      addedAt: DateTime.now(),
      categoryIds: categoryIds,
    );

    _books.add(newBook);
    _bookOwners[newBook.id] = userId;
    return newBook;
  }

  @override
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    List<String>? categoryIds,
  }) async {
    await _simulateDelay();
    if (shouldThrowOnUpdateBook) {
      throw Exception(errorMessage);
    }

    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) {
      throw Exception('Book not found: $bookId');
    }

    final oldBook = _books[index];
    _books[index] = Book(
      id: oldBook.id,
      title: title ?? oldBook.title,
      author: author ?? oldBook.author,
      isbn: isbn ?? oldBook.isbn,
      publisher: publisher ?? oldBook.publisher,
      publishDate: publishDate ?? oldBook.publishDate,
      coverImage: coverImage ?? oldBook.coverImage,
      description: description ?? oldBook.description,
      pageCount: oldBook.pageCount,
      addedAt: oldBook.addedAt,
      categoryIds: categoryIds ?? oldBook.categoryIds,
    );
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await _simulateDelay();
    if (shouldThrowOnDeleteBook) {
      throw Exception(errorMessage);
    }

    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) {
      throw Exception('Book not found: $bookId');
    }
    _books.removeAt(index);
    _bookOwners.remove(bookId);
  }

  @override
  Future<List<BookSearchResult>> searchBooks(String query) async {
    await _simulateDelay();
    if (shouldThrowOnSearch) {
      throw Exception(errorMessage);
    }

    if (query.trim().isEmpty) {
      return [];
    }

    // 설정된 검색 결과가 있으면 반환
    if (_searchResults.isNotEmpty) {
      return _searchResults
          .where((r) =>
              r.title.toLowerCase().contains(query.toLowerCase()) ||
              r.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // 기본 검색 결과 (테스트용)
    return TestBookSearchResults.searchResults
        .where((r) =>
            r.title.toLowerCase().contains(query.toLowerCase()) ||
            r.author.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
