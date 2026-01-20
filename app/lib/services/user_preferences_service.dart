/// 사용자 설정 서비스
///
/// Supabase Database를 사용하여 사용자 온보딩 설정을 저장/조회합니다.
/// 독서 목표, 독서 빈도, 알림 설정 등 개인화 정보를 관리합니다.
library;

import 'package:flutter/material.dart';

import '../core/supabase.dart';

/// 사용자 설정 데이터 모델
class UserPreferences {
  final String id;
  final String userId;
  final List<String> readingGoals;
  final String? readingFrequency;
  final bool onboardingCompleted;

  /// 알림 활성화 여부
  final bool notificationEnabled;

  /// 알림 시간 (기본값: 21:00)
  final TimeOfDay notificationTime;

  /// 스마트 넛지 활성화 여부
  final bool smartNudgeEnabled;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.readingGoals,
    this.readingFrequency,
    required this.onboardingCompleted,
    this.notificationEnabled = false,
    this.notificationTime = const TimeOfDay(hour: 21, minute: 0),
    this.smartNudgeEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    // notification_time 파싱 (HH:MM:SS 형식)
    TimeOfDay notificationTime = const TimeOfDay(hour: 21, minute: 0);
    if (json['notification_time'] != null) {
      final timeParts = (json['notification_time'] as String).split(':');
      if (timeParts.length >= 2) {
        notificationTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 21,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }

    return UserPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      readingGoals: (json['reading_goals'] as List?)?.cast<String>() ?? [],
      readingFrequency: json['reading_frequency'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      notificationEnabled: json['notification_enabled'] as bool? ?? false,
      notificationTime: notificationTime,
      smartNudgeEnabled: json['smart_nudge_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 복사본 생성 (일부 필드 업데이트)
  UserPreferences copyWith({
    String? id,
    String? userId,
    List<String>? readingGoals,
    String? readingFrequency,
    bool? onboardingCompleted,
    bool? notificationEnabled,
    TimeOfDay? notificationTime,
    bool? smartNudgeEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingGoals: readingGoals ?? this.readingGoals,
      readingFrequency: readingFrequency ?? this.readingFrequency,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      smartNudgeEnabled: smartNudgeEnabled ?? this.smartNudgeEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  /// 알림 설정을 업데이트합니다.
  ///
  /// [userId] 사용자 ID
  /// [notificationEnabled] 알림 활성화 여부
  /// [notificationTime] 알림 시간
  /// [smartNudgeEnabled] 스마트 넛지 활성화 여부
  Future<UserPreferences> updateNotificationSettings({
    required String userId,
    bool? notificationEnabled,
    TimeOfDay? notificationTime,
    bool? smartNudgeEnabled,
  }) async {
    final data = <String, dynamic>{
      'user_id': userId,
    };

    if (notificationEnabled != null) {
      data['notification_enabled'] = notificationEnabled;
    }
    if (notificationTime != null) {
      // TimeOfDay를 HH:MM:SS 형식으로 변환
      final hour = notificationTime.hour.toString().padLeft(2, '0');
      final minute = notificationTime.minute.toString().padLeft(2, '0');
      data['notification_time'] = '$hour:$minute:00';
    }
    if (smartNudgeEnabled != null) {
      data['smart_nudge_enabled'] = smartNudgeEnabled;
    }

    final response = await supabase
        .from('user_preferences')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();

    return UserPreferences.fromJson(response);
  }
}
