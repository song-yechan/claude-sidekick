import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/note.dart';

void main() {
  group('Note', () {
    test('fromJson creates Note correctly', () {
      final json = {
        'id': 'note-123',
        'book_id': 'book-456',
        'content': '테스트 내용입니다.',
        'summary': '테스트 요약',
        'page_number': 42,
        'tags': ['태그1', '태그2'],
        'memo': '테스트 메모',
        'created_at': '2024-01-20T10:30:00Z',
        'updated_at': '2024-01-21T15:45:00Z',
      };

      final note = Note.fromJson(json);

      expect(note.id, 'note-123');
      expect(note.bookId, 'book-456');
      expect(note.content, '테스트 내용입니다.');
      expect(note.summary, '테스트 요약');
      expect(note.pageNumber, 42);
      expect(note.tags, ['태그1', '태그2']);
      expect(note.memo, '테스트 메모');
      expect(note.createdAt, DateTime.parse('2024-01-20T10:30:00Z'));
      expect(note.updatedAt, DateTime.parse('2024-01-21T15:45:00Z'));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'note-123',
        'book_id': 'book-456',
        'content': '테스트 내용',
        'created_at': '2024-01-20T10:30:00Z',
        'updated_at': '2024-01-20T10:30:00Z',
      };

      final note = Note.fromJson(json);

      expect(note.id, 'note-123');
      expect(note.summary, isNull);
      expect(note.pageNumber, isNull);
      expect(note.tags, isEmpty);
      expect(note.memo, isNull);
    });

    test('toJson returns correct map', () {
      final note = Note(
        id: 'note-123',
        bookId: 'book-456',
        content: '테스트 내용',
        summary: '테스트 요약',
        pageNumber: 42,
        tags: ['태그1', '태그2'],
        memo: '테스트 메모',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
        updatedAt: DateTime.parse('2024-01-21T15:45:00Z'),
      );

      final json = note.toJson();

      expect(json['book_id'], 'book-456');
      expect(json['content'], '테스트 내용');
      expect(json['summary'], '테스트 요약');
      expect(json['page_number'], 42);
      expect(json['tags'], ['태그1', '태그2']);
      expect(json['memo'], '테스트 메모');
      // id, created_at, updated_at은 toJson에 포함되지 않음
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('copyWith creates new Note with updated fields', () {
      final note = Note(
        id: 'note-123',
        bookId: 'book-456',
        content: '원본 내용',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
        updatedAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final updatedNote = note.copyWith(
        content: '수정된 내용',
        summary: '새 요약',
        pageNumber: 100,
      );

      expect(updatedNote.id, 'note-123');
      expect(updatedNote.bookId, 'book-456');
      expect(updatedNote.content, '수정된 내용');
      expect(updatedNote.summary, '새 요약');
      expect(updatedNote.pageNumber, 100);
    });

    test('copyWith preserves original values when not specified', () {
      final note = Note(
        id: 'note-123',
        bookId: 'book-456',
        content: '원본 내용',
        summary: '원본 요약',
        pageNumber: 50,
        tags: ['태그1'],
        memo: '원본 메모',
        createdAt: DateTime.parse('2024-01-20T10:30:00Z'),
        updatedAt: DateTime.parse('2024-01-20T10:30:00Z'),
      );

      final updatedNote = note.copyWith(content: '수정된 내용');

      expect(updatedNote.summary, '원본 요약');
      expect(updatedNote.pageNumber, 50);
      expect(updatedNote.tags, ['태그1']);
      expect(updatedNote.memo, '원본 메모');
    });
  });
}
