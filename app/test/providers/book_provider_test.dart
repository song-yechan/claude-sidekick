import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/book_provider.dart';
import 'package:bookscribe/models/book.dart';

void main() {
  group('BookSearchState', () {
    test('기본 생성자는 빈 상태', () {
      const state = BookSearchState();

      expect(state.isLoading, isFalse);
      expect(state.results, isEmpty);
      expect(state.error, isNull);
    });

    test('copyWith으로 isLoading 변경', () {
      const state = BookSearchState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
      expect(newState.results, isEmpty);
      expect(newState.error, isNull);
    });

    test('copyWith으로 results 설정', () {
      const state = BookSearchState(isLoading: true);
      final results = [
        BookSearchResult(
          isbn: '123',
          title: '테스트 책',
          author: '테스트 저자',
          publisher: '',
          publishDate: '',
          coverImage: '',
          description: '',
        ),
      ];
      final newState = state.copyWith(isLoading: false, results: results);

      expect(newState.isLoading, isFalse);
      expect(newState.results.length, 1);
      expect(newState.results.first.title, '테스트 책');
    });

    test('copyWith으로 error 설정', () {
      const state = BookSearchState(isLoading: true);
      final newState = state.copyWith(isLoading: false, error: '검색 실패');

      expect(newState.isLoading, isFalse);
      expect(newState.error, '검색 실패');
    });

    test('error가 설정되면 이전 results는 유지', () {
      final results = [
        BookSearchResult(
          isbn: '123',
          title: '기존 책',
          author: '기존 저자',
          publisher: '',
          publishDate: '',
          coverImage: '',
          description: '',
        ),
      ];
      final state = BookSearchState(results: results);
      final newState = state.copyWith(error: '새 에러');

      expect(newState.results.length, 1);
      expect(newState.results.first.title, '기존 책');
      expect(newState.error, '새 에러');
    });
  });

  group('Book 모델 추가 테스트', () {
    test('pageCount가 포함된 Book fromJson', () {
      final json = {
        'id': 'book-123',
        'title': '테스트 책',
        'author': '테스트 저자',
        'page_count': 300,
        'added_at': '2024-01-20T10:30:00Z',
      };

      final book = Book.fromJson(json);

      expect(book.pageCount, 300);
    });

    test('pageCount가 null인 경우', () {
      final json = {
        'id': 'book-123',
        'title': '테스트 책',
        'author': '테스트 저자',
        'added_at': '2024-01-20T10:30:00Z',
      };

      final book = Book.fromJson(json);

      expect(book.pageCount, isNull);
    });

    test('copyWith으로 pageCount 변경', () {
      final book = Book(
        id: 'book-123',
        title: '테스트 책',
        author: '테스트 저자',
        addedAt: DateTime.now(),
        pageCount: 200,
      );

      final updatedBook = book.copyWith(pageCount: 350);

      expect(updatedBook.pageCount, 350);
    });
  });

  group('BookSearchResult 추가 테스트', () {
    test('pageCount가 포함된 fromJson', () {
      final json = {
        'isbn': '978-123',
        'title': '검색된 책',
        'author': '검색 저자',
        'publisher': '출판사',
        'publishDate': '2024-01-01',
        'coverImage': 'https://example.com/cover.jpg',
        'description': '설명',
        'pageCount': 450,
      };

      final result = BookSearchResult.fromJson(json);

      expect(result.pageCount, 450);
    });

    test('pageCount가 null인 경우', () {
      final json = {
        'isbn': '978-123',
        'title': '검색된 책',
        'author': '검색 저자',
      };

      final result = BookSearchResult.fromJson(json);

      expect(result.pageCount, isNull);
    });
  });
}
