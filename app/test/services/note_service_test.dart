/// NoteService 테스트
///
/// MockNoteService를 사용하여 노트 서비스의 동작을 검증합니다.
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mocks.dart';

void main() {
  late MockNoteService noteService;

  setUp(() {
    noteService = MockNoteService();
  });

  tearDown(() {
    noteService.reset();
  });

  group('getNotes', () {
    test('사용자의 모든 노트를 반환한다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final notes = await noteService.getNotes(TestUsers.userId1);

      // Then
      expect(notes.length, 3);
    });

    test('최신순으로 정렬된다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final notes = await noteService.getNotes(TestUsers.userId1);

      // Then
      expect(notes.first.id, TestNotes.noteId3); // 가장 최근
      expect(notes.last.id, TestNotes.noteId1); // 가장 오래된
    });

    test('다른 사용자의 노트는 반환하지 않는다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final notes = await noteService.getNotes(TestUsers.userId2);

      // Then
      expect(notes, isEmpty);
    });
  });

  group('getNotesByBook', () {
    test('특정 책의 노트만 반환한다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final notes = await noteService.getNotesByBook(TestBooks.bookId1);

      // Then
      expect(notes.length, 2); // 해리포터 책의 노트 2개
      expect(notes.every((n) => n.bookId == TestBooks.bookId1), true);
    });

    test('노트가 없는 책은 빈 리스트를 반환한다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final notes = await noteService.getNotesByBook(TestBooks.bookId3);

      // Then
      expect(notes, isEmpty);
    });
  });

  group('addNote', () {
    test('새 노트를 추가한다', () async {
      // When
      final note = await noteService.addNote(
        bookId: TestBooks.bookId1,
        userId: TestUsers.userId1,
        content: '새로운 노트 내용',
        pageNumber: 100,
      );

      // Then
      expect(note.content, '새로운 노트 내용');
      expect(note.pageNumber, 100);
      expect(noteService.notes.length, 1);
    });

    test('페이지 번호 없이도 노트를 추가할 수 있다', () async {
      // When
      final note = await noteService.addNote(
        bookId: TestBooks.bookId1,
        userId: TestUsers.userId1,
        content: '페이지 번호 없는 노트',
      );

      // Then
      expect(note.content, '페이지 번호 없는 노트');
      expect(note.pageNumber, isNull);
    });
  });

  group('updateNote', () {
    test('노트 내용을 수정한다', () async {
      // Given
      noteService.seedNotes([TestNotes.note1]);

      // When
      await noteService.updateNote(
        noteId: TestNotes.noteId1,
        content: '수정된 내용',
      );

      // Then
      final updated = noteService.notes.first;
      expect(updated.content, '수정된 내용');
      expect(updated.pageNumber, 42); // 변경되지 않음
    });

    test('페이지 번호를 수정한다', () async {
      // Given
      noteService.seedNotes([TestNotes.note1]);

      // When
      await noteService.updateNote(
        noteId: TestNotes.noteId1,
        pageNumber: 999,
      );

      // Then
      final updated = noteService.notes.first;
      expect(updated.pageNumber, 999);
    });

    test('존재하지 않는 노트 수정 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => noteService.updateNote(
          noteId: 'non-existent',
          content: '새 내용',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteNote', () {
    test('노트를 삭제한다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);
      expect(noteService.notes.length, 3);

      // When
      await noteService.deleteNote(TestNotes.noteId1);

      // Then
      expect(noteService.notes.length, 2);
      expect(noteService.notes.any((n) => n.id == TestNotes.noteId1), false);
    });

    test('존재하지 않는 노트 삭제 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => noteService.deleteNote('non-existent'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getNoteCountsByDate', () {
    test('날짜별 노트 개수를 반환한다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final counts = await noteService.getNoteCountsByDate(
        TestUsers.userId1,
        2024,
      );

      // Then
      expect(counts.length, 3); // 3개의 다른 날짜
      expect(counts[DateTime(2024, 1, 20)], 1);
      expect(counts[DateTime(2024, 1, 25)], 1);
      expect(counts[DateTime(2024, 2, 5)], 1);
    });

    test('다른 연도의 노트는 포함하지 않는다', () async {
      // Given
      noteService.seedNotes(TestNotes.all);

      // When
      final counts = await noteService.getNoteCountsByDate(
        TestUsers.userId1,
        2023,
      );

      // Then
      expect(counts, isEmpty);
    });

    test('같은 날짜의 노트 개수를 합산한다', () async {
      // Given
      await noteService.addNote(
        bookId: TestBooks.bookId1,
        userId: TestUsers.userId1,
        content: '첫 번째 노트',
      );
      await noteService.addNote(
        bookId: TestBooks.bookId1,
        userId: TestUsers.userId1,
        content: '두 번째 노트',
      );

      // When
      final counts = await noteService.getNoteCountsByDate(
        TestUsers.userId1,
        DateTime.now().year,
      );

      // Then
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      expect(counts[today], 2);
    });
  });

  group('에러 시뮬레이션', () {
    test('getNotes 에러를 시뮬레이션할 수 있다', () async {
      // Given
      noteService.shouldThrowOnGetNotes = true;

      // When & Then
      expect(
        () => noteService.getNotes(TestUsers.userId1),
        throwsA(isA<Exception>()),
      );
    });

    test('addNote 에러를 시뮬레이션할 수 있다', () async {
      // Given
      noteService.shouldThrowOnAddNote = true;

      // When & Then
      expect(
        () => noteService.addNote(
          bookId: TestBooks.bookId1,
          userId: TestUsers.userId1,
          content: '내용',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
