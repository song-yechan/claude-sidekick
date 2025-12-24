/// 온보딩 상태 관리 Provider
///
/// 이 파일은 앱의 온보딩(첫 실행 시 사용자 가이드) 상태를 관리합니다.
/// SharedPreferences를 사용하여 온보딩 완료 여부와 사용자 선택을 저장합니다.
///
/// 주요 기능:
/// - 온보딩 완료 여부 확인 및 저장
/// - 사용자 목표 및 독서 빈도 저장
/// - A/B 테스트를 위한 온보딩 화면 변형 관리
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// SharedPreferences를 사용하여 온보딩 관련 데이터를 영구 저장하고,
/// 앱 시작 시 저장된 상태를 불러옵니다.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  /// SharedPreferences 저장 키들
  static const String _onboardingKey = 'onboarding_completed';
  static const String _variantKey = 'onboarding_variant';
  static const String _goalsKey = 'user_goals';
  static const String _frequencyKey = 'reading_frequency';

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  /// 저장된 온보딩 상태를 불러옵니다.
  Future<void> _loadOnboardingStatus() async {
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
  }

  /// 온보딩을 완료하고 사용자 선택을 저장합니다.
  ///
  /// [goals] 사용자가 선택한 목표들
  /// [frequency] 사용자가 선택한 독서 빈도
  Future<void> completeOnboarding({
    List<String>? goals,
    String? frequency,
  }) async {
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
