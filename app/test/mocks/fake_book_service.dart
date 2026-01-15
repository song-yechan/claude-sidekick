/// Fake BookService for testing
///
/// BookSearchNotifier 및 book provider 테스트를 위한 Fake 구현체입니다.
/// 실제 Supabase 호출 없이 다양한 시나리오를 테스트할 수 있습니다.
library;

import 'package:bookscribe/models/book.dart';
import 'package:bookscribe/providers/language_provider.dart';
import 'package:bookscribe/services/book_service.dart';
import 'test_fixtures.dart';

/// 테스트용 Fake BookService
class FakeBookService implements IBookService {
  /// 내부 저장소
  final List<Book> _books = [];
  final Map<String, String> _bookOwners = {};

  /// 검색 결과로 반환할 데이터
  List<BookSearchResult> searchResults = [];

  /// 에러 시뮬레이션
  Exception? getBooksError;
  Exception? addBookError;
  Exception? updateBookError;
  Exception? deleteBookError;
  Exception? searchError;

  /// 호출 추적
  int getBooksCallCount = 0;
  int addBookCallCount = 0;
  int updateBookCallCount = 0;
  int deleteBookCallCount = 0;
  int searchCallCount = 0;

  /// 마지막 검색 쿼리
  String? lastSearchQuery;

  FakeBookService();

  void reset() {
    _books.clear();
    _bookOwners.clear();
    searchResults = [];
    getBooksError = null;
    addBookError = null;
    updateBookError = null;
    deleteBookError = null;
    searchError = null;
    getBooksCallCount = 0;
    addBookCallCount = 0;
    updateBookCallCount = 0;
    deleteBookCallCount = 0;
    searchCallCount = 0;
    lastSearchQuery = null;
  }

  /// 테스트용 책 데이터 시드
  void seedBooks(List<Book> books, {String? userId}) {
    final ownerId = userId ?? TestUsers.userId1;
    for (final book in books) {
      _books.add(book);
      _bookOwners[book.id] = ownerId;
    }
  }

  List<Book> get books => List.unmodifiable(_books);

  @override
  Future<Book?> findDuplicateBook({
    required String userId,
    String? isbn,
    String? title,
    String? author,
  }) async {
    // 간단한 중복 체크 로직
    for (final book in _books) {
      if (_bookOwners[book.id] != userId) continue;

      // ISBN이 있으면 ISBN으로 비교
      if (isbn != null && isbn.isNotEmpty && book.isbn == isbn) {
        return book;
      }

      // 제목과 저자로 비교
      if (title != null && author != null &&
          book.title == title && book.author == author) {
        return book;
      }
    }
    return null;
  }

  @override
  Future<List<Book>> getBooks(String userId) async {
    getBooksCallCount++;

    if (getBooksError != null) {
      throw getBooksError!;
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
    addBookCallCount++;

    if (addBookError != null) {
      throw addBookError!;
    }

    final newBook = Book(
      id: 'fake-book-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      author: author,
      isbn: isbn,
      publisher: publisher,
      publishDate: publishDate,
      coverImage: coverImage,
      description: description,
      pageCount: pageCount,
      categoryIds: categoryIds,
      addedAt: DateTime.now(),
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
    updateBookCallCount++;

    if (updateBookError != null) {
      throw updateBookError!;
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
      categoryIds: categoryIds ?? oldBook.categoryIds,
      addedAt: oldBook.addedAt,
    );
  }

  @override
  Future<void> deleteBook(String bookId) async {
    deleteBookCallCount++;

    if (deleteBookError != null) {
      throw deleteBookError!;
    }

    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) {
      throw Exception('Book not found: $bookId');
    }

    _books.removeAt(index);
    _bookOwners.remove(bookId);
  }

  @override
  Future<List<BookSearchResult>> searchBooks(String query, {AppLanguage language = AppLanguage.ko}) async {
    searchCallCount++;
    lastSearchQuery = query;

    if (searchError != null) {
      throw searchError!;
    }

    if (query.trim().isEmpty) {
      return [];
    }

    // 설정된 검색 결과가 있으면 반환
    if (searchResults.isNotEmpty) {
      return searchResults
          .where((r) =>
              r.title.toLowerCase().contains(query.toLowerCase()) ||
              r.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // 기본 검색 결과
    return TestBookSearchResults.searchResults
        .where((r) =>
            r.title.toLowerCase().contains(query.toLowerCase()) ||
            r.author.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
