/// BookSearchNotifier 테스트
///
/// FakeBookService를 사용하여 BookSearchNotifier의 동작을 검증합니다.
/// 실제 API 호출 없이 검색 로직을 테스트합니다.
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/book_provider.dart';
import 'package:bookscribe/models/book.dart';
import '../mocks/fake_book_service.dart';
import '../mocks/test_fixtures.dart';

void main() {
  late FakeBookService fakeBookService;
  late BookSearchNotifier notifier;

  setUp(() {
    fakeBookService = FakeBookService();
    notifier = BookSearchNotifier(fakeBookService);
  });

  tearDown(() {
    fakeBookService.reset();
  });

  group('초기 상태', () {
    test('초기 상태는 빈 검색 결과', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.error, isNull);
    });
  });

  group('search', () {
    test('빈 검색어는 상태를 초기화한다', () async {
      // Given - 이전 검색 결과가 있는 상태
      fakeBookService.searchResults = TestBookSearchResults.searchResults;
      await notifier.search('해리포터');
      expect(notifier.state.results, isNotEmpty);

      // When
      await notifier.search('');

      // Then
      expect(notifier.state.isLoading, false);
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.error, isNull);
    });

    test('공백만 있는 검색어도 상태를 초기화한다', () async {
      // When
      await notifier.search('   ');

      // Then
      expect(notifier.state.results, isEmpty);
      expect(fakeBookService.searchCallCount, 0);
    });

    test('검색 성공 시 결과를 반환한다', () async {
      // Given
      fakeBookService.searchResults = TestBookSearchResults.searchResults;

      // When
      await notifier.search('해리포터');

      // Then
      expect(notifier.state.isLoading, false);
      expect(notifier.state.results.length, 1);
      expect(notifier.state.results.first.title, contains('해리포터'));
      expect(notifier.state.error, isNull);
    });

    test('검색어로 필터링된 결과를 반환한다', () async {
      // Given
      fakeBookService.searchResults = TestBookSearchResults.searchResults;

      // When
      await notifier.search('습관');

      // Then
      expect(notifier.state.results.length, 1);
      expect(notifier.state.results.first.title, contains('습관'));
    });

    test('검색 실패 시 에러가 설정된다', () async {
      // Given
      fakeBookService.searchError = Exception('API 오류');

      // When
      await notifier.search('테스트');

      // Then
      expect(notifier.state.isLoading, false);
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.error, contains('API 오류'));
    });

    test('검색 시 BookService.searchBooks가 호출된다', () async {
      // When
      await notifier.search('테스트 쿼리');

      // Then
      expect(fakeBookService.searchCallCount, 1);
      expect(fakeBookService.lastSearchQuery, '테스트 쿼리');
    });

    test('여러 번 검색 시 호출 횟수가 증가한다', () async {
      // When
      await notifier.search('첫 번째');
      await notifier.search('두 번째');
      await notifier.search('세 번째');

      // Then
      expect(fakeBookService.searchCallCount, 3);
      expect(fakeBookService.lastSearchQuery, '세 번째');
    });

    test('검색 결과가 없을 때 빈 목록을 반환한다', () async {
      // Given
      fakeBookService.searchResults = TestBookSearchResults.searchResults;

      // When - 매칭되지 않는 쿼리
      await notifier.search('존재하지않는책');

      // Then
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.error, isNull);
    });
  });

  group('clear', () {
    test('clear 호출 시 상태가 초기화된다', () async {
      // Given
      fakeBookService.searchResults = TestBookSearchResults.searchResults;
      await notifier.search('해리포터');
      expect(notifier.state.results, isNotEmpty);

      // When
      notifier.clear();

      // Then
      expect(notifier.state.isLoading, false);
      expect(notifier.state.results, isEmpty);
      expect(notifier.state.error, isNull);
    });

    test('에러 상태도 clear로 초기화된다', () async {
      // Given
      fakeBookService.searchError = Exception('에러');
      await notifier.search('테스트');
      expect(notifier.state.error, isNotNull);

      // When
      notifier.clear();

      // Then
      expect(notifier.state.error, isNull);
    });
  });

  group('BookSearchState', () {
    test('기본 생성자는 빈 상태', () {
      const state = BookSearchState();

      expect(state.isLoading, false);
      expect(state.results, isEmpty);
      expect(state.error, isNull);
    });

    test('copyWith으로 isLoading 변경', () {
      const state = BookSearchState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, true);
      expect(newState.results, isEmpty);
      expect(newState.error, isNull);
    });

    test('copyWith으로 results 설정', () {
      const state = BookSearchState();
      final results = [TestBookSearchResults.harryPotter];
      final newState = state.copyWith(results: results);

      expect(newState.results.length, 1);
      expect(newState.isLoading, false);
    });

    test('copyWith으로 error 설정', () {
      const state = BookSearchState(isLoading: true);
      final newState = state.copyWith(isLoading: false, error: '에러 발생');

      expect(newState.isLoading, false);
      expect(newState.error, '에러 발생');
    });

    test('copyWith에서 error는 null로 초기화 가능', () {
      const state = BookSearchState(error: '기존 에러');
      final newState = state.copyWith(error: null);

      expect(newState.error, isNull);
    });
  });

  group('FakeBookService', () {
    test('seedBooks로 테스트 데이터를 추가할 수 있다', () async {
      // Given
      fakeBookService.seedBooks(TestBooks.all);

      // When
      final books = await fakeBookService.getBooks(TestUsers.userId1);

      // Then
      expect(books.length, 3);
    });

    test('다른 사용자의 책은 조회되지 않는다', () async {
      // Given
      fakeBookService.seedBooks(TestBooks.all, userId: TestUsers.userId1);

      // When
      final books = await fakeBookService.getBooks(TestUsers.userId2);

      // Then
      expect(books, isEmpty);
    });

    test('addBook으로 책을 추가할 수 있다', () async {
      // When
      final book = await fakeBookService.addBook(
        userId: TestUsers.userId1,
        title: '새 책',
        author: '저자',
      );

      // Then
      expect(book.title, '새 책');
      expect(fakeBookService.addBookCallCount, 1);
      expect(fakeBookService.books.length, 1);
    });

    test('updateBook으로 책을 수정할 수 있다', () async {
      // Given
      fakeBookService.seedBooks([TestBooks.harryPotter]);

      // When
      await fakeBookService.updateBook(
        bookId: TestBooks.bookId1,
        title: '수정된 제목',
      );

      // Then
      expect(fakeBookService.books.first.title, '수정된 제목');
      expect(fakeBookService.updateBookCallCount, 1);
    });

    test('deleteBook으로 책을 삭제할 수 있다', () async {
      // Given
      fakeBookService.seedBooks([TestBooks.harryPotter]);
      expect(fakeBookService.books.length, 1);

      // When
      await fakeBookService.deleteBook(TestBooks.bookId1);

      // Then
      expect(fakeBookService.books, isEmpty);
      expect(fakeBookService.deleteBookCallCount, 1);
    });

    test('존재하지 않는 책 삭제 시 에러', () async {
      // When & Then
      expect(
        () => fakeBookService.deleteBook('non-existent'),
        throwsA(isA<Exception>()),
      );
    });

    test('reset으로 모든 상태가 초기화된다', () async {
      // Given
      fakeBookService.seedBooks(TestBooks.all);
      await fakeBookService.searchBooks('테스트');

      // When
      fakeBookService.reset();

      // Then
      expect(fakeBookService.books, isEmpty);
      expect(fakeBookService.searchCallCount, 0);
      expect(fakeBookService.lastSearchQuery, isNull);
    });
  });

  group('에러 시뮬레이션', () {
    test('getBooks 에러 시뮬레이션', () async {
      // Given
      fakeBookService.getBooksError = Exception('DB 오류');

      // When & Then
      expect(
        () => fakeBookService.getBooks(TestUsers.userId1),
        throwsA(isA<Exception>()),
      );
    });

    test('addBook 에러 시뮬레이션', () async {
      // Given
      fakeBookService.addBookError = Exception('추가 실패');

      // When & Then
      expect(
        () => fakeBookService.addBook(
          userId: TestUsers.userId1,
          title: '제목',
          author: '저자',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('updateBook 에러 시뮬레이션', () async {
      // Given
      fakeBookService.seedBooks([TestBooks.harryPotter]);
      fakeBookService.updateBookError = Exception('수정 실패');

      // When & Then
      expect(
        () => fakeBookService.updateBook(bookId: TestBooks.bookId1),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteBook 에러 시뮬레이션', () async {
      // Given
      fakeBookService.seedBooks([TestBooks.harryPotter]);
      fakeBookService.deleteBookError = Exception('삭제 실패');

      // When & Then
      expect(
        () => fakeBookService.deleteBook(TestBooks.bookId1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
