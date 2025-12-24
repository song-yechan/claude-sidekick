import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 완료 상태를 관리하는 Provider
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

/// 온보딩 상태
class OnboardingState {
  final bool isCompleted;
  final bool isLoading;
  final int selectedVariant; // 0, 1, 2 for different variants
  final List<String> userGoals; // 사용자가 선택한 목표들
  final String? readingFrequency; // 독서 빈도

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

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _variantKey = 'onboarding_variant';
  static const String _goalsKey = 'user_goals';
  static const String _frequencyKey = 'reading_frequency';

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_onboardingKey) ?? false;
    final variant = prefs.getInt(_variantKey) ?? 1; // 기본값: variant 2
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

  /// 온보딩 완료 및 사용자 선택 저장
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

  Future<void> setVariant(int variant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_variantKey, variant);
    state = state.copyWith(selectedVariant: variant);
  }

  /// 사용자 목표 저장
  Future<void> setGoals(List<String> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_goalsKey, goals);
    state = state.copyWith(userGoals: goals);
  }

  /// 독서 빈도 저장
  Future<void> setFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frequencyKey, frequency);
    state = state.copyWith(readingFrequency: frequency);
  }
}
