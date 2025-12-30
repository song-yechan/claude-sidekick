/// 사용자 설정 서비스
///
/// Supabase Database를 사용하여 사용자 온보딩 설정을 저장/조회합니다.
/// 독서 목표, 독서 빈도 등 개인화 정보를 관리합니다.
library;

import '../core/supabase.dart';

/// 사용자 설정 데이터 모델
class UserPreferences {
  final String id;
  final String userId;
  final List<String> readingGoals;
  final String? readingFrequency;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.readingGoals,
    this.readingFrequency,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      readingGoals: (json['reading_goals'] as List?)?.cast<String>() ?? [],
      readingFrequency: json['reading_frequency'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// 사용자 설정 CRUD 기능을 제공하는 서비스 클래스
class UserPreferencesService {
  /// 특정 사용자의 설정을 조회합니다.
  ///
  /// [userId] 조회할 사용자의 ID
  /// 설정이 없으면 null 반환
  Future<UserPreferences?> getPreferences(String userId) async {
    final response = await supabase
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserPreferences.fromJson(response);
  }

  /// 사용자 설정을 저장합니다 (upsert).
  ///
  /// 기존 설정이 있으면 업데이트, 없으면 새로 생성합니다.
  Future<UserPreferences> savePreferences({
    required String userId,
    List<String>? readingGoals,
    String? readingFrequency,
    bool? onboardingCompleted,
  }) async {
    final data = {
      'user_id': userId,
      if (readingGoals != null) 'reading_goals': readingGoals,
      if (readingFrequency != null) 'reading_frequency': readingFrequency,
      if (onboardingCompleted != null) 'onboarding_completed': onboardingCompleted,
    };

    final response = await supabase
        .from('user_preferences')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();

    return UserPreferences.fromJson(response);
  }

  /// 온보딩 완료 상태를 저장합니다.
  Future<void> completeOnboarding({
    required String userId,
    List<String>? goals,
    String? frequency,
  }) async {
    await savePreferences(
      userId: userId,
      readingGoals: goals,
      readingFrequency: frequency,
      onboardingCompleted: true,
    );
  }
}
