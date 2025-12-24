/// 노트 서비스
///
/// Supabase Database를 사용하여 노트(수집한 문장) 데이터의 CRUD 작업을 처리합니다.
///
/// 주요 테이블:
/// - notes: 노트 정보 저장 (책과 1:N 관계)
library;

import '../core/supabase.dart';
import '../models/note.dart';

/// 노트 데이터 CRUD 기능을 제공하는 서비스 클래스
class NoteService {
  /// 특정 사용자의 모든 노트를 조회합니다.
  ///
  /// [userId] 조회할 사용자의 ID
  /// 최신 생성순으로 정렬됩니다.
  Future<List<Note>> getNotes(String userId) async {
    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  /// 특정 책에 속한 노트들을 조회합니다.
  ///
  /// [bookId] 조회할 책의 ID
  /// 최신 생성순으로 정렬됩니다.
  Future<List<Note>> getNotesByBook(String bookId) async {
    final response = await supabase
        .from('notes')
        .select()
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json)).toList();
  }

  /// 새 노트를 추가합니다.
  ///
  /// [userId] 사용자 ID
  /// [bookId] 이 노트가 속할 책의 ID
  /// [content] 수집한 문장 (원문)
  /// [summary] AI가 생성한 요약 (선택)
  /// [pageNumber] 책의 페이지 번호 (선택)
  /// [tags] 태그 목록 (선택)
  /// [memo] 사용자 메모 (선택)
  ///
  /// 반환값: 생성된 Note 객체
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

  /// 기존 노트를 수정합니다.
  ///
  /// [noteId] 수정할 노트의 ID
  /// null이 아닌 필드만 업데이트됩니다.
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

  /// 노트를 삭제합니다.
  ///
  /// [noteId] 삭제할 노트의 ID
  Future<void> deleteNote(String noteId) async {
    await supabase.from('notes').delete().eq('id', noteId);
  }

  /// 특정 연도의 날짜별 노트 수를 집계합니다.
  ///
  /// [userId] 사용자 ID
  /// [year] 집계할 연도
  ///
  /// 홈 화면의 활동 캘린더(GitHub 스타일 잔디)에서 사용됩니다.
  /// 반환값: {날짜: 해당 날짜의 노트 수} Map
  Future<Map<DateTime, int>> getNoteCountsByDate(String userId, int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);

    final response = await supabase
        .from('notes')
        .select('created_at')
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());

    // 날짜별로 그룹화하여 카운트
    final counts = <DateTime, int>{};
    for (final row in response as List) {
      final date = DateTime.parse(row['created_at'] as String);
      // 시간 정보를 제거하고 날짜만 사용
      final dateOnly = DateTime(date.year, date.month, date.day);
      counts[dateOnly] = (counts[dateOnly] ?? 0) + 1;
    }

    return counts;
  }
}
