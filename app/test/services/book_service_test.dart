/// BookService 테스트
///
/// MockBookService를 사용하여 BookService의 동작을 검증합니다.
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mocks.dart';

void main() {
  late MockBookService bookService;

  setUp(() {
    bookService = MockBookService();
  });

  tearDown(() {
    bookService.reset();
  });

  group('getBooks', () {
    test('사용자의 책 목록을 반환한다', () async {
      // Given
      bookService.seedBooks(TestBooks.all);

      // When
      final books = await bookService.getBooks(TestUsers.userId1);

      // Then
      expect(books.length, 3);
      expect(books.first.title, '해리포터와 마법사의 돌');
    });

    test('다른 사용자의 책은 반환하지 않는다', () async {
      // Given
      bookService.seedBooks(TestBooks.all);

      // When
      final books = await bookService.getBooks(TestUsers.userId2);

      // Then
      expect(books.length, 0);
    });

    test('에러 발생 시 예외를 던진다', () async {
      // Given
      bookService.shouldThrowOnGetBooks = true;
      bookService.errorMessage = 'Database connection failed';

      // When & Then
      expect(
        () => bookService.getBooks(TestUsers.userId1),
        throwsA(isA<Exception>()),
      );
    });

    test('빈 목록일 때 빈 리스트를 반환한다', () async {
      // Given (책 없음)

      // When
      final books = await bookService.getBooks(TestUsers.userId1);

      // Then
      expect(books, isEmpty);
    });
  });

  group('addBook', () {
    test('새 책을 추가한다', () async {
      // When
      final book = await bookService.addBook(
        userId: TestUsers.userId1,
        title: '새로운 책',
        author: '새 저자',
        isbn: '1234567890',
        categoryIds: [TestCategories.categoryId1],
      );

      // Then
      expect(book.title, '새로운 책');
      expect(book.author, '새 저자');
      expect(book.categoryIds, contains(TestCategories.categoryId1));
      expect(bookService.books.length, 1);
    });

    test('카테고리 없이 책을 추가할 수 있다', () async {
      // When
      final book = await bookService.addBook(
        userId: TestUsers.userId1,
        title: '카테고리 없는 책',
        author: '저자',
      );

      // Then
      expect(book.categoryIds, isEmpty);
    });

    test('에러 발생 시 예외를 던진다', () async {
      // Given
      bookService.shouldThrowOnAddBook = true;

      // When & Then
      expect(
        () => bookService.addBook(
          userId: TestUsers.userId1,
          title: '책',
          author: '저자',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateBook', () {
    test('책 정보를 업데이트한다', () async {
      // Given
      bookService.seedBooks([TestBooks.harryPotter]);

      // When
      await bookService.updateBook(
        bookId: TestBooks.bookId1,
        title: '수정된 제목',
      );

      // Then
      final updated = bookService.books.first;
      expect(updated.title, '수정된 제목');
      expect(updated.author, 'J.K. 롤링'); // 변경되지 않음
    });

    test('카테고리를 업데이트한다', () async {
      // Given
      bookService.seedBooks([TestBooks.harryPotter]);

      // When
      await bookService.updateBook(
        bookId: TestBooks.bookId1,
        categoryIds: [TestCategories.categoryId2, TestCategories.categoryId3],
      );

      // Then
      final updated = bookService.books.first;
      expect(updated.categoryIds.length, 2);
      expect(updated.categoryIds, contains(TestCategories.categoryId2));
    });

    test('존재하지 않는 책 업데이트 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => bookService.updateBook(
          bookId: 'non-existent',
          title: '새 제목',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteBook', () {
    test('책을 삭제한다', () async {
      // Given
      bookService.seedBooks([TestBooks.harryPotter, TestBooks.atomicHabits]);
      expect(bookService.books.length, 2);

      // When
      await bookService.deleteBook(TestBooks.bookId1);

      // Then
      expect(bookService.books.length, 1);
      expect(bookService.books.first.id, TestBooks.bookId2);
    });

    test('존재하지 않는 책 삭제 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => bookService.deleteBook('non-existent'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('searchBooks', () {
    test('검색어로 책을 검색한다', () async {
      // When
      final results = await bookService.searchBooks('해리');

      // Then
      expect(results.isNotEmpty, true);
      expect(results.first.title, contains('해리포터'));
    });

    test('빈 검색어는 빈 결과를 반환한다', () async {
      // When
      final results = await bookService.searchBooks('');

      // Then
      expect(results, isEmpty);
    });

    test('공백만 있는 검색어는 빈 결과를 반환한다', () async {
      // When
      final results = await bookService.searchBooks('   ');

      // Then
      expect(results, isEmpty);
    });

    test('일치하지 않는 검색어는 빈 결과를 반환한다', () async {
      // When
      final results = await bookService.searchBooks('존재하지않는책제목xyz');

      // Then
      expect(results, isEmpty);
    });

    test('에러 발생 시 예외를 던진다', () async {
      // Given
      bookService.shouldThrowOnSearch = true;

      // When & Then
      expect(
        () => bookService.searchBooks('검색어'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('지연 시뮬레이션', () {
    test('지연을 시뮬레이션할 수 있다', () async {
      // Given
      bookService.delayMs = 100;
      final stopwatch = Stopwatch()..start();

      // When
      await bookService.getBooks(TestUsers.userId1);

      // Then
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
