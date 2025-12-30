/// OnboardingProvider 테스트
///
/// 온보딩 상태 관리 및 OnboardingState를 검증합니다.
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/onboarding_provider.dart';

void main() {
  group('OnboardingState', () {
    test('default constructor has correct initial values', () {
      const state = OnboardingState();

      expect(state.isCompleted, false);
      expect(state.isLoading, true);
      expect(state.selectedVariant, 1);
      expect(state.userGoals, isEmpty);
      expect(state.readingFrequency, isNull);
    });

    test('constructor with custom values', () {
      const state = OnboardingState(
        isCompleted: true,
        isLoading: false,
        selectedVariant: 2,
        userGoals: ['goal1', 'goal2'],
        readingFrequency: 'daily',
      );

      expect(state.isCompleted, true);
      expect(state.isLoading, false);
      expect(state.selectedVariant, 2);
      expect(state.userGoals, ['goal1', 'goal2']);
      expect(state.readingFrequency, 'daily');
    });

    test('copyWith preserves original values when not specified', () {
      const original = OnboardingState(
        isCompleted: true,
        isLoading: false,
        selectedVariant: 2,
        userGoals: ['goal1'],
        readingFrequency: 'weekly',
      );

      final copied = original.copyWith();

      expect(copied.isCompleted, original.isCompleted);
      expect(copied.isLoading, original.isLoading);
      expect(copied.selectedVariant, original.selectedVariant);
      expect(copied.userGoals, original.userGoals);
      expect(copied.readingFrequency, original.readingFrequency);
    });

    test('copyWith updates isCompleted', () {
      const original = OnboardingState(isCompleted: false);
      final copied = original.copyWith(isCompleted: true);

      expect(copied.isCompleted, true);
      expect(original.isCompleted, false);
    });

    test('copyWith updates isLoading', () {
      const original = OnboardingState(isLoading: true);
      final copied = original.copyWith(isLoading: false);

      expect(copied.isLoading, false);
    });

    test('copyWith updates selectedVariant', () {
      const original = OnboardingState(selectedVariant: 1);
      final copied = original.copyWith(selectedVariant: 0);

      expect(copied.selectedVariant, 0);
    });

    test('copyWith updates userGoals', () {
      const original = OnboardingState(userGoals: []);
      final copied = original.copyWith(userGoals: ['new goal']);

      expect(copied.userGoals, ['new goal']);
    });

    test('copyWith updates readingFrequency', () {
      const original = OnboardingState();
      final copied = original.copyWith(readingFrequency: 'monthly');

      expect(copied.readingFrequency, 'monthly');
    });

    test('copyWith can update multiple fields', () {
      const original = OnboardingState();
      final copied = original.copyWith(
        isCompleted: true,
        isLoading: false,
        userGoals: ['a', 'b'],
        readingFrequency: 'daily',
      );

      expect(copied.isCompleted, true);
      expect(copied.isLoading, false);
      expect(copied.userGoals, ['a', 'b']);
      expect(copied.readingFrequency, 'daily');
    });

    test('userGoals is immutable by default', () {
      const state = OnboardingState();
      expect(state.userGoals, isA<List<String>>());
      expect(state.userGoals.isEmpty, true);
    });
  });

  group('OnboardingState variants', () {
    test('variant 0 is valid', () {
      const state = OnboardingState(selectedVariant: 0);
      expect(state.selectedVariant, 0);
    });

    test('variant 1 is default', () {
      const state = OnboardingState();
      expect(state.selectedVariant, 1);
    });

    test('variant 2 is valid', () {
      const state = OnboardingState(selectedVariant: 2);
      expect(state.selectedVariant, 2);
    });
  });

  group('OnboardingState reading frequency', () {
    test('can be null', () {
      const state = OnboardingState();
      expect(state.readingFrequency, isNull);
    });

    test('can be set to daily', () {
      const state = OnboardingState(readingFrequency: 'daily');
      expect(state.readingFrequency, 'daily');
    });

    test('can be set to weekly', () {
      const state = OnboardingState(readingFrequency: 'weekly');
      expect(state.readingFrequency, 'weekly');
    });

    test('can be set to monthly', () {
      const state = OnboardingState(readingFrequency: 'monthly');
      expect(state.readingFrequency, 'monthly');
    });
  });
}
