/// SplashScreen 테스트
///
/// 스플래시 화면의 UI 요소와 기본 렌더링을 검증합니다.
/// 애니메이션과 타이머 기반 테스트는 복잡성으로 인해 통합 테스트에서 수행합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookscribe/screens/splash/splash_screen.dart';
import 'package:bookscribe/providers/auth_provider.dart';
import 'package:bookscribe/providers/onboarding_provider.dart';

void main() {
  Widget buildSplashScreen({
    AuthState? authState,
    OnboardingState? onboardingState,
  }) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => TestAuthNotifier(
              authState ?? const AuthState(isLoading: true),
            )),
        onboardingProvider.overrideWith((ref) => TestOnboardingNotifier(
              onboardingState ?? const OnboardingState(isLoading: true),
            )),
      ],
      child: const MaterialApp(
        home: SplashScreen(),
      ),
    );
  }

  group('SplashScreen', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSplashScreen());

      expect(find.byType(SplashScreen), findsOneWidget);

      // 타이머 정리를 위해 충분한 시간 진행
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows app logo image', (tester) async {
      await tester.pumpWidget(buildSplashScreen());

      expect(find.byType(Image), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('has scaffold structure', (tester) async {
      await tester.pumpWidget(buildSplashScreen());

      expect(find.byType(Scaffold), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });
  });
}

/// 테스트용 AuthNotifier
class TestAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  TestAuthNotifier(AuthState initialState) : super(initialState);

  @override
  Future<bool> signIn(String email, String password) async => true;

  @override
  Future<bool> signUp(String email, String password) async => true;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> deleteAccount() async => true;

  @override
  void continueToApp() {}

  @override
  void goToLogin() {}

  @override
  void dispose() {
    super.dispose();
  }
}

/// 테스트용 OnboardingNotifier
class TestOnboardingNotifier extends StateNotifier<OnboardingState>
    implements OnboardingNotifier {
  TestOnboardingNotifier(OnboardingState initialState) : super(initialState);

  @override
  Future<void> completeOnboarding({
    List<String>? goals,
    String? frequency,
  }) async {
    state = OnboardingState(isCompleted: true, isLoading: false);
  }

  @override
  Future<void> resetOnboarding() async {
    state = const OnboardingState(isCompleted: false, isLoading: false);
  }

  @override
  Future<void> setVariant(int variant) async {
    state = state.copyWith(selectedVariant: variant);
  }

  @override
  Future<void> setGoals(List<String> goals) async {
    state = state.copyWith(userGoals: goals);
  }

  @override
  Future<void> setFrequency(String frequency) async {
    state = state.copyWith(readingFrequency: frequency);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
