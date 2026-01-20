/// 알림 상태 관리 Provider
///
/// 알림 설정의 조회, 수정, 스케줄링을 담당합니다.
/// Riverpod을 사용하여 상태를 관리합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nudge.dart';
import '../services/notification_service.dart';
import '../services/user_preferences_service.dart';
import 'auth_provider.dart';
import 'streak_provider.dart';

/// 알림 서비스 인스턴스 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// 알림 설정 상태 클래스
class NotificationSettings {
  final bool enabled;
  final TimeOfDay time;
  final bool smartNudgeEnabled;
  final bool hasPermission;

  const NotificationSettings({
    this.enabled = false,
    this.time = const TimeOfDay(hour: 21, minute: 0),
    this.smartNudgeEnabled = true,
    this.hasPermission = false,
  });

  NotificationSettings copyWith({
    bool? enabled,
    TimeOfDay? time,
    bool? smartNudgeEnabled,
    bool? hasPermission,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      time: time ?? this.time,
      smartNudgeEnabled: smartNudgeEnabled ?? this.smartNudgeEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

/// 알림 설정 Provider
///
/// 사용자의 알림 설정을 조회합니다.
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) {
    return const NotificationSettings();
  }

  final preferencesService = UserPreferencesService();
  final prefs = await preferencesService.getPreferences(authState.user!.id);

  final notificationService = ref.watch(notificationServiceProvider);
  final hasPermission = await notificationService.hasPermission();

  if (prefs == null) {
    return NotificationSettings(hasPermission: hasPermission);
  }

  return NotificationSettings(
    enabled: prefs.notificationEnabled,
    time: prefs.notificationTime,
    smartNudgeEnabled: prefs.smartNudgeEnabled,
    hasPermission: hasPermission,
  );
});

/// 알림 상태 클래스
class NotificationState {
  final NotificationSettings settings;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.settings = const NotificationSettings(),
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 알림 상태 관리 StateNotifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(const NotificationState());

  /// 알림 설정을 로드합니다.
  Future<void> loadSettings() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final preferencesService = UserPreferencesService();
      final prefs = await preferencesService.getPreferences(authState.user!.id);

      final notificationService = _ref.read(notificationServiceProvider);
      final hasPermission = await notificationService.hasPermission();

      if (prefs != null) {
        state = NotificationState(
          settings: NotificationSettings(
            enabled: prefs.notificationEnabled,
            time: prefs.notificationTime,
            smartNudgeEnabled: prefs.smartNudgeEnabled,
            hasPermission: hasPermission,
          ),
          isLoading: false,
        );
      } else {
        state = NotificationState(
          settings: NotificationSettings(hasPermission: hasPermission),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '알림 설정을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 알림 활성화/비활성화
  Future<bool> setNotificationEnabled(bool enabled) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return false;

    // 활성화 시 권한 확인 및 요청
    if (enabled) {
      final notificationService = _ref.read(notificationServiceProvider);
      var hasPermission = await notificationService.hasPermission();

      if (!hasPermission) {
        hasPermission = await notificationService.requestPermission();
        if (!hasPermission) {
          state = state.copyWith(
            settings: state.settings.copyWith(hasPermission: false),
          );
          return false;
        }
      }

      state = state.copyWith(
        settings: state.settings.copyWith(hasPermission: true),
      );
    }

    state = state.copyWith(isLoading: true);

    try {
      final preferencesService = UserPreferencesService();
      await preferencesService.updateNotificationSettings(
        userId: authState.user!.id,
        notificationEnabled: enabled,
      );

      state = state.copyWith(
        settings: state.settings.copyWith(enabled: enabled),
        isLoading: false,
      );

      // 알림 스케줄링
      await _updateNotificationSchedule();

      // Provider 갱신
      _ref.invalidate(notificationSettingsProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '설정 저장에 실패했습니다.',
      );
      return false;
    }
  }

  /// 알림 시간 변경
  Future<bool> setNotificationTime(TimeOfDay time) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final preferencesService = UserPreferencesService();
      await preferencesService.updateNotificationSettings(
        userId: authState.user!.id,
        notificationTime: time,
      );

      state = state.copyWith(
        settings: state.settings.copyWith(time: time),
        isLoading: false,
      );

      // 알림 재스케줄링
      await _updateNotificationSchedule();

      // Provider 갱신
      _ref.invalidate(notificationSettingsProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '설정 저장에 실패했습니다.',
      );
      return false;
    }
  }

  /// 스마트 넛지 활성화/비활성화
  Future<bool> setSmartNudgeEnabled(bool enabled) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final preferencesService = UserPreferencesService();
      await preferencesService.updateNotificationSettings(
        userId: authState.user!.id,
        smartNudgeEnabled: enabled,
      );

      state = state.copyWith(
        settings: state.settings.copyWith(smartNudgeEnabled: enabled),
        isLoading: false,
      );

      // 알림 재스케줄링
      await _updateNotificationSchedule();

      // Provider 갱신
      _ref.invalidate(notificationSettingsProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '설정 저장에 실패했습니다.',
      );
      return false;
    }
  }

  /// 알림 스케줄 업데이트
  Future<void> _updateNotificationSchedule() async {
    final notificationService = _ref.read(notificationServiceProvider);
    final settings = state.settings;

    if (!settings.enabled) {
      await notificationService.cancelDailyReminder();
      return;
    }

    // 스마트 넛지 활성화 시 넛지 레벨에 따른 메시지 사용
    if (settings.smartNudgeEnabled) {
      final nudgeLevel = _ref.read(nudgeLevelProvider);
      final streakData = _ref.read(streakProvider).valueOrNull;

      await notificationService.scheduleSmartNudge(
        time: settings.time,
        level: nudgeLevel,
        streakData: streakData,
        messageGenerator: _generateNudgeMessage,
      );
    } else {
      // 기본 메시지 사용
      await notificationService.scheduleDailyReminder(
        time: settings.time,
        title: '독서 시간',
        body: '오늘의 독서 시간이에요! 📚',
      );
    }
  }

  /// 넛지 레벨에 따른 메시지 생성
  String _generateNudgeMessage(NudgeLevel level, int? currentStreak) {
    switch (level) {
      case NudgeLevel.normal:
        return '오늘의 독서 시간이에요! 📚';
      case NudgeLevel.gentle:
        return '어제 못 읽었죠? 오늘은 어때요?';
      case NudgeLevel.moderate:
        if (currentStreak != null && currentStreak > 0) {
          return '$currentStreak일 연속 기록을 이어가세요!';
        }
        return '독서 습관을 이어가세요!';
      case NudgeLevel.strong:
        return '책이 기다리고 있어요. 다시 시작해볼까요?';
    }
  }
}

/// 알림 StateNotifier Provider
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});
