import '../core/supabase.dart';
import '../models/note.dart';

class NoteService {
  /// 사용자의 모든 노트 조회
  Future<List<Note>> getNotes(String userId) async {
    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  /// 특정 책의 노트 조회
  Future<List<Note>> getNotesByBook(String bookId) async {
    final response = await supabase
        .from('notes')
        .select()
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  /// 노트 추가
  Future<Note> addNote({
    required String userId,
    required String bookId,
    required String content,
    String? summary,
    int? pageNumber,
    List<String> tags = const [],
    String? memo,
  }) async {
    final response = await supabase
        .from('notes')
        .insert({
          'user_id': userId,
          'book_id': bookId,
          'content': content,
          'summary': summary,
          'page_number': pageNumber,
          'tags': tags,
          'memo': memo,
        })
        .select()
        .single();

    return Note.fromJson(response);
  }

  /// 노트 수정
  Future<void> updateNote({
    required String noteId,
    String? content,
    String? summary,
    int? pageNumber,
    List<String>? tags,
    String? memo,
  }) async {
    final updates = <String, dynamic>{};
    if (content != null) updates['content'] = content;
    if (summary != null) updates['summary'] = summary;
    if (pageNumber != null) updates['page_number'] = pageNumber;
    if (tags != null) updates['tags'] = tags;
    if (memo != null) updates['memo'] = memo;

    if (updates.isNotEmpty) {
      await supabase.from('notes').update(updates).eq('id', noteId);
    }
  }

  /// 노트 삭제
  Future<void> deleteNote(String noteId) async {
    await supabase.from('notes').delete().eq('id', noteId);
  }

  /// 날짜별 노트 수 조회 (활동 캘린더용)
  Future<Map<DateTime, int>> getNoteCountsByDate(String userId, int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);

    final response = await supabase
        .from('notes')
        .select('created_at')
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());

    final counts = <DateTime, int>{};
    for (final row in response as List) {
      final date = DateTime.parse(row['created_at'] as String);
      final dateOnly = DateTime(date.year, date.month, date.day);
      counts[dateOnly] = (counts[dateOnly] ?? 0) + 1;
    }

    return counts;
  }
}
