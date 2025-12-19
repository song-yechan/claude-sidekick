import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/book.dart';

void main() {
  group('Book', () {
    test('fromJson creates Book correctly', () {
      final json = {
        'id': 'book-123',
        'isbn': '978-1234567890',
        'title': '테스트 책',
        'author': '테스트 저자',
        'publisher': '테스트 출판사',
        'publish_date': '2024-01-15',
        'cover_image': 'https://example.com/cover.jpg',
        'description': '테스트 설명',
        'added_at': '2024-01-20T10:30:00Z',
      };

      final book = Book.fromJson(json, categoryIds: ['cat-1', 'cat-2']);

      expect(book.id, 'book-123');
      expect(book.isbn, '978-1234567890');
      expect(book.title, '테스트 책');
      expect(book.author, '테스트 저자');
      expect(book.publisher, '테스트 출판사');
      expect(book.publishDate, '2024-01-15');
      expect(book.coverImage, 'https://example.com/cover.jpg');
      expect(book.description, '테스트 설명');
      expect(book.categoryIds, ['cat-1', 'cat-2']);
      expect(book.addedAt, DateTime.parse('2024-01-20T10:30:00Z'));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'book-123',
        'title': '테스트 책',
        'author': '테스트 저자',
        'added_at': '2024-01-20T10:30:00Z',
      };

      final book = Book.fromJson(json);

      expect(book.id, 'book-123');
      expect(book.isbn, isNull);
      expect(book.publisher, isNull);
      expect(book.publishDate, isNull);
      expect(book.coverImage, isNull);
      expect(book.description, isNull);
      expect(book.categoryIds, isEmpty);
    });

    test('toJson returns correct map', () {
      final book = Book(
        id: 'book-123',
        isbn: '978-1234567890',
        title: '테스트 책',
        author: '테스트 저자',
        publisher: '테스트 출판사',
        publishDate: '2024-01-15',
        coverImage: 'https://example.com/cover.jpg',
        description: '테스트 설명',
        addedAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final json = book.toJson();

      expect(json['isbn'], '978-1234567890');
      expect(json['title'], '테스트 책');
      expect(json['author'], '테스트 저자');
      expect(json['publisher'], '테스트 출판사');
      expect(json['publish_date'], '2024-01-15');
      expect(json['cover_image'], 'https://example.com/cover.jpg');
      expect(json['description'], '테스트 설명');
      // id와 added_at은 toJson에 포함되지 않음
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('added_at'), isFalse);
    });

    test('copyWith creates new Book with updated fields', () {
      final book = Book(
        id: 'book-123',
        title: '원본 제목',
        author: '원본 저자',
        addedAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final updatedBook = book.copyWith(
        title: '수정된 제목',
        publisher: '새 출판사',
      );

      expect(updatedBook.id, 'book-123');
      expect(updatedBook.title, '수정된 제목');
      expect(updatedBook.author, '원본 저자');
      expect(updatedBook.publisher, '새 출판사');
    });
  });

  group('BookSearchResult', () {
    test('fromJson creates BookSearchResult correctly', () {
      final json = {
        'isbn': '978-1234567890',
        'title': '검색된 책',
        'author': '검색 저자',
        'publisher': '검색 출판사',
        'publishDate': '2024-01-15',
        'coverImage': 'https://example.com/cover.jpg',
        'description': '검색 설명',
      };

      final result = BookSearchResult.fromJson(json);

      expect(result.isbn, '978-1234567890');
      expect(result.title, '검색된 책');
      expect(result.author, '검색 저자');
      expect(result.publisher, '검색 출판사');
      expect(result.publishDate, '2024-01-15');
      expect(result.coverImage, 'https://example.com/cover.jpg');
      expect(result.description, '검색 설명');
    });

    test('fromJson handles null values with empty strings', () {
      final json = <String, dynamic>{};

      final result = BookSearchResult.fromJson(json);

      expect(result.isbn, '');
      expect(result.title, '');
      expect(result.author, '');
      expect(result.publisher, '');
      expect(result.publishDate, '');
      expect(result.coverImage, '');
      expect(result.description, '');
    });

    test('fromJson handles partial data', () {
      final json = {
        'title': '부분 데이터 책',
        'author': '부분 저자',
      };

      final result = BookSearchResult.fromJson(json);

      expect(result.title, '부분 데이터 책');
      expect(result.author, '부분 저자');
      expect(result.isbn, '');
      expect(result.publisher, '');
    });
  });
}
