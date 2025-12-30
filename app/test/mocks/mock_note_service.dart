/// Mock NoteService
///
/// 테스트용 NoteService 모킹 클래스입니다.
/// 실제 Supabase 호출 없이 테스트할 수 있도록 합니다.
library;

import 'package:bookscribe/models/note.dart';
import 'test_fixtures.dart';

/// NoteService 인터페이스
abstract class INoteService {
  Future<List<Note>> getNotes(String userId);
  Future<List<Note>> getNotesByBook(String bookId);
  Future<Note> addNote({
    required String bookId,
    required String userId,
    required String content,
    int? pageNumber,
  });
  Future<void> updateNote({
    required String noteId,
    String? content,
    int? pageNumber,
  });
  Future<void> deleteNote(String noteId);
  Future<Map<DateTime, int>> getNoteCountsByDate(String userId, int year);
}

/// Mock NoteService
class MockNoteService implements INoteService {
  /// 내부 저장소 (메모리)
  final List<Note> _notes = [];
  /// 노트 ID -> 사용자 ID 매핑 (DB에서는 user_id 컬럼으로 관리)
  final Map<String, String> _noteOwners = {};

  /// 에러 시뮬레이션용 플래그
  bool shouldThrowOnGetNotes = false;
  bool shouldThrowOnGetNotesByBook = false;
  bool shouldThrowOnAddNote = false;
  bool shouldThrowOnUpdateNote = false;
  bool shouldThrowOnDeleteNote = false;
  bool shouldThrowOnGetCounts = false;

  String errorMessage = 'Mock error';
  int delayMs = 0;

  MockNoteService() {
    reset();
  }

  void reset() {
    _notes.clear();
    _noteOwners.clear();
    shouldThrowOnGetNotes = false;
    shouldThrowOnGetNotesByBook = false;
    shouldThrowOnAddNote = false;
    shouldThrowOnUpdateNote = false;
    shouldThrowOnDeleteNote = false;
    shouldThrowOnGetCounts = false;
    errorMessage = 'Mock error';
    delayMs = 0;
  }

  /// 테스트용 노트 추가 (사용자 지정)
  void seedNotes(List<Note> notes, {String? userId}) {
    final ownerId = userId ?? TestUsers.userId1;
    for (final note in notes) {
      _notes.add(note);
      _noteOwners[note.id] = ownerId;
    }
  }

  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> _simulateDelay() async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  @override
  Future<List<Note>> getNotes(String userId) async {
    await _simulateDelay();
    if (shouldThrowOnGetNotes) throw Exception(errorMessage);
    return _notes.where((n) => _noteOwners[n.id] == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Note>> getNotesByBook(String bookId) async {
    await _simulateDelay();
    if (shouldThrowOnGetNotesByBook) throw Exception(errorMessage);
    return _notes.where((n) => n.bookId == bookId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Note> addNote({
    required String bookId,
    required String userId,
    required String content,
    int? pageNumber,
  }) async {
    await _simulateDelay();
    if (shouldThrowOnAddNote) throw Exception(errorMessage);

    final now = DateTime.now();
    final newNote = Note(
      id: 'mock-note-${now.millisecondsSinceEpoch}',
      bookId: bookId,
      content: content,
      pageNumber: pageNumber,
      createdAt: now,
      updatedAt: now,
    );

    _notes.add(newNote);
    _noteOwners[newNote.id] = userId;
    return newNote;
  }

  @override
  Future<void> updateNote({
    required String noteId,
    String? content,
    int? pageNumber,
  }) async {
    await _simulateDelay();
    if (shouldThrowOnUpdateNote) throw Exception(errorMessage);

    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) throw Exception('Note not found: $noteId');

    final oldNote = _notes[index];
    _notes[index] = Note(
      id: oldNote.id,
      bookId: oldNote.bookId,
      content: content ?? oldNote.content,
      pageNumber: pageNumber ?? oldNote.pageNumber,
      summary: oldNote.summary,
      tags: oldNote.tags,
      memo: oldNote.memo,
      createdAt: oldNote.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _simulateDelay();
    if (shouldThrowOnDeleteNote) throw Exception(errorMessage);

    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index == -1) throw Exception('Note not found: $noteId');
    _notes.removeAt(index);
    _noteOwners.remove(noteId);
  }

  @override
  Future<Map<DateTime, int>> getNoteCountsByDate(String userId, int year) async {
    await _simulateDelay();
    if (shouldThrowOnGetCounts) throw Exception(errorMessage);

    final counts = <DateTime, int>{};
    final userNotes = _notes.where((n) =>
        _noteOwners[n.id] == userId && n.createdAt.year == year);

    for (final note in userNotes) {
      final date = DateTime(
        note.createdAt.year,
        note.createdAt.month,
        note.createdAt.day,
      );
      counts[date] = (counts[date] ?? 0) + 1;
    }

    return counts;
  }
}
