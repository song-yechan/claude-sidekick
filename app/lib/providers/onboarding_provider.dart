/// 온보딩 상태 관리 Provider
///
/// 이 파일은 앱의 온보딩(첫 실행 시 사용자 가이드) 상태를 관리합니다.
/// SharedPreferences를 사용하여 로컬 캐싱하고,
/// Supabase를 통해 클라우드에 동기화합니다.
///
/// 주요 기능:
/// - 온보딩 완료 여부 확인 및 저장
/// - 사용자 목표 및 독서 빈도 저장 (로컬 + 클라우드)
/// - A/B 테스트를 위한 온보딩 화면 변형 관리
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_preferences_service.dart';
import '../core/supabase.dart';
import '../core/airbridge_service.dart';

/// 온보딩 상태를 관리하는 Provider
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

/// 온보딩 상태를 나타내는 불변 클래스
///
/// 온보딩 완료 여부, 사용자 선택 정보 등을 포함합니다.
class OnboardingState {
  /// 온보딩 완료 여부
  final bool isCompleted;

  /// 상태 로딩 중 여부
  final bool isLoading;

  /// 온보딩 화면 변형 (A/B 테스트용, 0/1/2)
  final int selectedVariant;

  /// 사용자가 선택한 앱 사용 목표들
  final List<String> userGoals;

  /// 사용자가 선택한 독서 빈도
  final String? readingFrequency;

  const OnboardingState({
    this.isCompleted = false,
    this.isLoading = true,
    this.selectedVariant = 1, // 기본값: 인터랙티브형 (variant 2)
    this.userGoals = const [],
    this.readingFrequency,
  });

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isLoading,
    int? selectedVariant,
    List<String>? userGoals,
    String? readingFrequency,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      userGoals: userGoals ?? this.userGoals,
      readingFrequency: readingFrequency ?? this.readingFrequency,
    );
  }
}

/// 온보딩 상태를 관리하는 StateNotifier
///
/// SharedPreferences를 사용하여 로컬에 캐싱하고,
/// Supabase를 통해 클라우드에 동기화합니다.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  /// SharedPreferences 저장 키들
  static const String _onboardingKey = 'onboarding_completed';
  static const String _variantKey = 'onboarding_variant';
  static const String _goalsKey = 'user_goals';
  static const String _frequencyKey = 'reading_frequency';

  final UserPreferencesService _preferencesService = UserPreferencesService();

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  /// 저장된 온보딩 상태를 불러옵니다.
  /// 먼저 로컬에서 빠르게 로드하고, 로그인된 경우 클라우드에서 동기화합니다.
  Future<void> _loadOnboardingStatus() async {
    // 1. 로컬에서 먼저 로드 (빠른 응답)
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_onboardingKey) ?? false;
    final variant = prefs.getInt(_variantKey) ?? 1;
    final goals = prefs.getStringList(_goalsKey) ?? [];
    final frequency = prefs.getString(_frequencyKey);

    state = state.copyWith(
      isCompleted: isCompleted,
      isLoading: false,
      selectedVariant: variant,
      userGoals: goals,
      readingFrequency: frequency,
    );

    // 2. 로그인된 경우 클라우드에서 동기화
    await _syncFromCloud();
  }

  /// 클라우드에서 설정을 동기화합니다.
  Future<void> _syncFromCloud() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cloudPrefs = await _preferencesService.getPreferences(userId);
      if (cloudPrefs != null) {
        // 클라우드 데이터로 로컬 업데이트
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_onboardingKey, cloudPrefs.onboardingCompleted);
        await prefs.setStringList(_goalsKey, cloudPrefs.readingGoals);
        if (cloudPrefs.readingFrequency != null) {
          await prefs.setString(_frequencyKey, cloudPrefs.readingFrequency!);
        }

        state = state.copyWith(
          isCompleted: cloudPrefs.onboardingCompleted,
          userGoals: cloudPrefs.readingGoals,
          readingFrequency: cloudPrefs.readingFrequency,
        );
      }
    } catch (e) {
      debugPrint('Failed to sync from cloud: $e');
    }
  }

  /// 온보딩을 완료하고 사용자 선택을 저장합니다.
  ///
  /// [goals] 사용자가 선택한 목표들
  /// [frequency] 사용자가 선택한 독서 빈도
  Future<void> completeOnboarding({
    List<String>? goals,
    String? frequency,
  }) async {
    // 1. 로컬에 저장 (오프라인 지원)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);

    if (goals != null) {
      await prefs.setStringList(_goalsKey, goals);
    }
    if (frequency != null) {
      await prefs.setString(_frequencyKey, frequency);
    }

    state = state.copyWith(
      isCompleted: true,
      userGoals: goals ?? state.userGoals,
      readingFrequency: frequency ?? state.readingFrequency,
    );

    // Airbridge 이벤트 트래킹
    AirbridgeService.trackOnboardingCompleted(
      goals: goals,
      readingFrequency: frequency,
    );

    // 2. 클라우드에 저장 (동기화)
    await _saveToCloud(goals: goals, frequency: frequency);
  }

  /// 클라우드에 설정을 저장합니다.
  Future<void> _saveToCloud({
    List<String>? goals,
    String? frequency,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('User not logged in, skipping cloud save');
        return;
      }

      await _preferencesService.completeOnboarding(
        userId: userId,
        goals: goals,
        frequency: frequency,
      );
      debugPrint('Onboarding data saved to cloud');
    } catch (e) {
      debugPrint('Failed to save to cloud: $e');
    }
  }

  /// 온보딩 상태를 초기화합니다.
  ///
  /// 디버그/테스트 목적으로 사용합니다.
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
    await prefs.remove(_goalsKey);
    await prefs.remove(_frequencyKey);
    state = state.copyWith(
      isCompleted: false,
      userGoals: [],
      readingFrequency: null,
    );
  }

  /// 온보딩 화면 변형을 설정합니다 (A/B 테스트용).
  ///
  /// [variant] 화면 변형 번호 (0, 1, 2)
  Future<void> setVariant(int variant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_variantKey, variant);
    state = state.copyWith(selectedVariant: variant);
  }

  /// 사용자 목표를 저장합니다.
  ///
  /// [goals] 사용자가 선택한 목표 목록
  Future<void> setGoals(List<String> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_goalsKey, goals);
    state = state.copyWith(userGoals: goals);
  }

  /// 독서 빈도를 저장합니다.
  ///
  /// [frequency] 사용자가 선택한 독서 빈도
  Future<void> setFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frequencyKey, frequency);
    state = state.copyWith(readingFrequency: frequency);
  }
}
