/// AuthScreen 테스트
///
/// 인증 화면의 UI 요소와 사용자 인터랙션을 검증합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bookscribe/l10n/app_localizations.dart';
import 'package:bookscribe/screens/auth/auth_screen.dart';
import 'package:bookscribe/providers/auth_provider.dart';

void main() {
  Widget buildAuthScreen({AuthState? initialState}) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) {
          return TestAuthNotifier(initialState ?? const AuthState());
        }),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('ko'),
        home: const AuthScreen(),
      ),
    );
  }

  group('AuthScreen 로그인 모드', () {
    testWidgets('shows login mode by default', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.text('로그인'), findsWidgets);
      expect(find.text('다시 만나서 반가워요'), findsOneWidget);
    });

    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('비밀번호'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows login button', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);
    });

    testWidgets('shows signup toggle link', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.text('계정이 없으신가요? 회원가입'), findsOneWidget);
    });

    testWidgets('shows app branding', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.text('BookScribe'), findsOneWidget);
      expect(find.text('책 속 문장을 나만의 기록으로'), findsOneWidget);
    });

    testWidgets('email validation shows error for empty email', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();

      expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    });

    testWidgets('email validation shows error for invalid format', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'invalid-email',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();

      expect(find.text('올바른 이메일 형식이 아닙니다'), findsOneWidget);
    });

    testWidgets('password validation shows error for empty password', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();

      expect(find.text('비밀번호를 입력해주세요'), findsOneWidget);
    });

    testWidgets('password validation shows error for short password', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '12345',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pump();

      expect(find.text('비밀번호는 6자 이상이어야 합니다'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('AuthScreen 회원가입 모드', () {
    testWidgets('switches to signup mode when toggle tapped', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      // 스크롤해서 토글 버튼을 보이게 함
      final toggleButton = find.textContaining('회원가입');
      await tester.ensureVisible(toggleButton.last);
      await tester.pumpAndSettle();

      await tester.tap(toggleButton.last);
      await tester.pump();

      expect(find.text('간단한 가입으로 시작하세요'), findsOneWidget);
    });

    testWidgets('shows password confirm field in signup mode', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      final toggleButton = find.textContaining('회원가입');
      await tester.ensureVisible(toggleButton.last);
      await tester.pumpAndSettle();

      await tester.tap(toggleButton.last);
      await tester.pump();

      expect(find.text('비밀번호 확인'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('shows signup button in signup mode', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      final toggleButton = find.textContaining('회원가입');
      await tester.ensureVisible(toggleButton.last);
      await tester.pumpAndSettle();

      await tester.tap(toggleButton.last);
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, '가입하기'), findsOneWidget);
    });

    testWidgets('shows login toggle link in signup mode', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      final toggleButton = find.textContaining('회원가입');
      await tester.ensureVisible(toggleButton.last);
      await tester.pumpAndSettle();

      await tester.tap(toggleButton.last);
      await tester.pump();

      expect(find.textContaining('로그인'), findsWidgets);
    });

    testWidgets('password confirm validation shows error when mismatch', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      final toggleButton = find.textContaining('회원가입');
      await tester.ensureVisible(toggleButton.last);
      await tester.pumpAndSettle();

      await tester.tap(toggleButton.last);
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'different123');

      // 스크롤해서 가입하기 버튼이 보이게 함
      final signUpButton = find.widgetWithText(ElevatedButton, '가입하기');
      await tester.ensureVisible(signUpButton);
      await tester.pumpAndSettle();

      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text('비밀번호가 일치하지 않습니다'), findsOneWidget);
    });

    testWidgets('can switch back to login mode', (tester) async {
      await tester.pumpWidget(buildAuthScreen());

      // 회원가입 모드로 전환
      final signupToggle = find.textContaining('회원가입');
      await tester.ensureVisible(signupToggle.last);
      await tester.pumpAndSettle();
      await tester.tap(signupToggle.last);
      await tester.pump();

      // 다시 로그인 모드로 전환
      final loginToggle = find.textContaining('로그인');
      await tester.ensureVisible(loginToggle.last);
      await tester.pumpAndSettle();
      await tester.tap(loginToggle.last);
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('AuthScreen 로딩 상태', () {
    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildAuthScreen(
          initialState: const AuthState(isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables button when loading', (tester) async {
      await tester.pumpWidget(
        buildAuthScreen(
          initialState: const AuthState(isLoading: true),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });
  });

  group('AuthScreen 회원가입 완료 화면', () {
    testWidgets('shows signup complete screen when signUpCompleted is true', (tester) async {
      await tester.pumpWidget(
        buildAuthScreen(
          initialState: const AuthState(signUpCompleted: true),
        ),
      );

      expect(find.text('환영합니다!'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('shows success icon on complete screen', (tester) async {
      await tester.pumpWidget(
        buildAuthScreen(
          initialState: const AuthState(signUpCompleted: true),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('shows welcome message on complete screen', (tester) async {
      await tester.pumpWidget(
        buildAuthScreen(
          initialState: const AuthState(signUpCompleted: true),
        ),
      );

      expect(find.textContaining('BookScribe와 함께'), findsOneWidget);
    });
  });
}

/// 테스트용 AuthNotifier
class TestAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  TestAuthNotifier(AuthState initialState) : super(initialState);

  @override
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(isLoading: false);
    return true;
  }

  @override
  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(isLoading: false, signUpCompleted: true);
    return true;
  }

  @override
  Future<void> signOut() async {
    state = const AuthState();
  }

  @override
  Future<bool> deleteAccount() async {
    state = const AuthState();
    return true;
  }

  @override
  void continueToApp() {
    state = state.copyWith(signUpCompleted: false);
  }

  @override
  void goToLogin() {
    state = const AuthState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
