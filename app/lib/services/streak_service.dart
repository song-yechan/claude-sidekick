/// 스트릭 서비스
///
/// 연속 독서 일수 추적 및 계산을 담당합니다.
/// Supabase Database의 reading_streaks 테이블과 통신합니다.
library;

import '../core/supabase.dart';
import '../models/streak.dart';
import 'note_service.dart';

/// 스트릭 데이터 CRUD 및 계산 기능을 제공하는 서비스 클래스
class StreakService {
  final NoteService _noteService = NoteService();

  /// 사용자의 현재 스트릭 데이터를 조회합니다.
  ///
  /// [userId] 조회할 사용자의 ID
  /// 데이터가 없으면 null 반환
  Future<StreakData?> getStreak(String userId) async {
    final response = await supabase
        .from('reading_streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return StreakData.fromJson(response);
  }

  /// 스트릭 데이터를 생성하거나 업데이트합니다.
  ///
  /// 노트 작성 후 호출되어 스트릭을 갱신합니다.
  /// 오늘 이미 활동했다면 변경 없이 기존 데이터 반환.
  Future<StreakData> updateStreak(String userId) async {
    final existing = await getStreak(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (existing == null) {
      // 첫 활동: 새 스트릭 레코드 생성
      return _createStreak(userId, today);
    }

    // 오늘 이미 활동했으면 업데이트 불필요
    if (existing.isActiveToday) {
      return existing;
    }

    // 스트릭 계산
    final lastActive = existing.lastActiveDate;
    int newStreak;
    DateTime? newStreakStartDate;

    if (lastActive == null) {
      // 첫 활동
      newStreak = 1;
      newStreakStartDate = today;
    } else {
      final lastActiveDate = DateTime(
        lastActive.year,
        lastActive.month,
        lastActive.day,
      );
      final daysDiff = today.difference(lastActiveDate).inDays;

      if (daysDiff == 1) {
        // 연속 유지 (어제 활동)
        newStreak = existing.currentStreak + 1;
        newStreakStartDate = existing.streakStartDate;
      } else if (daysDiff == 0) {
        // 같은 날 (이미 위에서 처리됨, 안전장치)
        return existing;
      } else {
        // 연속 끊김 (2일 이상 미활동)
        newStreak = 1;
        newStreakStartDate = today;
      }
    }

    // 최장 기록 갱신
    final newLongest =
        newStreak > existing.longestStreak ? newStreak : existing.longestStreak;

    // DB 업데이트
    final response = await supabase
        .from('reading_streaks')
        .update({
          'current_streak': newStreak,
          'longest_streak': newLongest,
          'last_active_date': today.toIso8601String().split('T')[0],
          'streak_start_date':
              newStreakStartDate?.toIso8601String().split('T')[0],
        })
        .eq('user_id', userId)
        .select()
        .single();

    return StreakData.fromJson(response);
  }

  /// 새 스트릭 레코드를 생성합니다.
  Future<StreakData> _createStreak(String userId, DateTime today) async {
    final response = await supabase
        .from('reading_streaks')
        .insert({
          'user_id': userId,
          'current_streak': 1,
          'longest_streak': 1,
          'last_active_date': today.toIso8601String().split('T')[0],
          'streak_start_date': today.toIso8601String().split('T')[0],
        })
        .select()
        .single();

    return StreakData.fromJson(response);
  }

  /// 스트릭을 재계산합니다.
  ///
  /// 앱 시작 시 또는 데이터 무결성 확인이 필요할 때 호출합니다.
  /// 노트 데이터를 기반으로 스트릭을 재계산하여 동기화합니다.
  Future<StreakData> recalculateStreak(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 최근 1년간의 노트 활동 조회
    final noteCounts = await _noteService.getNoteCountsByDate(userId, now.year);

    // 이전 연도 데이터도 포함 (연초에 작년 스트릭이 이어질 수 있음)
    if (now.month <= 2) {
      final lastYearCounts =
          await _noteService.getNoteCountsByDate(userId, now.year - 1);
      noteCounts.addAll(lastYearCounts);
    }

    // 활동 날짜 목록 (정렬)
    final activeDates = noteCounts.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 최신순

    if (activeDates.isEmpty) {
      // 활동 기록 없음
      return _getOrCreateEmptyStreak(userId);
    }

    // 연속 일수 계산 (오늘 또는 어제부터 시작)
    int currentStreak = 0;
    DateTime? streakStartDate;
    DateTime checkDate = today;

    // 오늘 활동이 없으면 어제부터 확인
    final todayHasActivity = activeDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);

    if (!todayHasActivity) {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayHasActivity = activeDates.any((d) =>
          d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day);

      if (!yesterdayHasActivity) {
        // 어제도 활동 없음 → 스트릭 0
        return _updateStreakData(
          userId,
          currentStreak: 0,
          longestStreak: await _calculateLongestStreak(activeDates),
          lastActiveDate: activeDates.isNotEmpty ? activeDates.first : null,
          streakStartDate: null,
        );
      }
      checkDate = yesterday;
    }

    // 연속 일수 계산
    while (true) {
      final hasActivity = activeDates.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);

      if (hasActivity) {
        currentStreak++;
        streakStartDate = checkDate;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // 최장 기록 계산
    final longestStreak = await _calculateLongestStreak(activeDates);

    return _updateStreakData(
      userId,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: activeDates.first,
      streakStartDate: streakStartDate,
    );
  }

  /// 활동 날짜 목록에서 최장 연속 기록을 계산합니다.
  Future<int> _calculateLongestStreak(List<DateTime> activeDates) async {
    if (activeDates.isEmpty) return 0;

    // 날짜 정렬 (오래된 순)
    final sortedDates = activeDates.toList()..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final curr = sortedDates[i];
      final diff = curr.difference(prev).inDays;

      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0인 경우 (같은 날) 무시
    }

    return longest;
  }

  /// 빈 스트릭 데이터를 조회하거나 생성합니다.
  Future<StreakData> _getOrCreateEmptyStreak(String userId) async {
    final existing = await getStreak(userId);
    if (existing != null) {
      return existing.copyWith(
        currentStreak: 0,
        streakStartDate: null,
      );
    }

    final response = await supabase
        .from('reading_streaks')
        .insert({
          'user_id': userId,
          'current_streak': 0,
          'longest_streak': 0,
        })
        .select()
        .single();

    return StreakData.fromJson(response);
  }

  /// 스트릭 데이터를 업데이트합니다.
  Future<StreakData> _updateStreakData(
    String userId, {
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActiveDate,
    DateTime? streakStartDate,
  }) async {
    final existing = await getStreak(userId);

    final data = {
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String().split('T')[0],
      'streak_start_date': streakStartDate?.toIso8601String().split('T')[0],
    };

    if (existing == null) {
      final response = await supabase
          .from('reading_streaks')
          .insert(data)
          .select()
          .single();
      return StreakData.fromJson(response);
    } else {
      final response = await supabase
          .from('reading_streaks')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();
      return StreakData.fromJson(response);
    }
  }
}
