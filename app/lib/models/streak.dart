/// 스트릭(연속 독서) 데이터 모델
///
/// 사용자의 연속 독서 일수를 추적합니다.
library;

/// 스트릭 데이터 모델
class StreakData {
  /// 데이터베이스 ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 현재 연속 독서 일수
  final int currentStreak;

  /// 최장 연속 독서 기록
  final int longestStreak;

  /// 마지막 독서 활동 날짜
  final DateTime? lastActiveDate;

  /// 현재 스트릭 시작 날짜
  final DateTime? streakStartDate;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  StreakData({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    this.streakStartDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 StreakData 객체 생성
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      streakStartDate: json['streak_start_date'] != null
          ? DateTime.parse(json['streak_start_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// StreakData 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String().split('T')[0],
      'streak_start_date': streakStartDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 오늘 활동했는지 여부
  bool get isActiveToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    return today.isAtSameMomentAs(lastActive);
  }

  /// 비활성 일수 계산
  int get inactiveDays {
    if (lastActiveDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    return today.difference(lastActive).inDays;
  }

  /// 복사본 생성 (일부 필드 업데이트)
  StreakData copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? streakStartDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StreakData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 기본값으로 초기화된 빈 스트릭 데이터
  factory StreakData.empty(String userId) {
    final now = DateTime.now();
    return StreakData(
      id: '',
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
      streakStartDate: null,
      createdAt: now,
      updatedAt: now,
    );
  }
}
