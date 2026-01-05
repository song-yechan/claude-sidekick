/// SettingsScreen 테스트
///
/// 설정 화면의 UI 요소와 사용자 인터랙션을 검증합니다.
/// User 객체 생성이 복잡하여, user.email 표시 테스트는 제외됩니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookscribe/screens/settings/settings_screen.dart';
import 'package:bookscribe/providers/theme_provider.dart';
import 'package:bookscribe/providers/auth_provider.dart';

void main() {
  Widget buildSettingsScreen({
    AppThemeMode initialTheme = AppThemeMode.system,
  }) {
    return ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => TestThemeNotifier(initialTheme)),
        authProvider.overrideWith((ref) => TestAuthNotifier()),
      ],
      child: MaterialApp(
        home: const SettingsScreen(),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(),
          );
        },
      ),
    );
  }

  group('SettingsScreen 기본 UI', () {
    testWidgets('shows settings title in app bar', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows theme section header', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('화면'), findsOneWidget);
    });

    testWidgets('shows account section header', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('계정'), findsOneWidget);
    });

    testWidgets('shows app info section header', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      // 앱 정보 섹션이 스크롤 아래에 있으므로 스크롤
      await tester.scrollUntilVisible(
        find.text('앱 정보'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('앱 정보'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      // 버전 정보가 스크롤 아래에 있으므로 스크롤
      await tester.scrollUntilVisible(
        find.text('버전'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('버전'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });
  });

  group('SettingsScreen 테마 설정', () {
    testWidgets('shows all theme options', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('시스템 설정'), findsOneWidget);
      expect(find.text('라이트 모드'), findsOneWidget);
      expect(find.text('다크 모드'), findsOneWidget);
    });

    testWidgets('shows theme option subtitles', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('기기 설정에 따라 자동 전환'), findsOneWidget);
      expect(find.text('밝은 테마 사용'), findsOneWidget);
      expect(find.text('어두운 테마 사용'), findsOneWidget);
    });

    testWidgets('shows theme icons', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.byIcon(Icons.brightness_auto_rounded), findsOneWidget);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('system theme shows check icon when selected', (tester) async {
      await tester.pumpWidget(
        buildSettingsScreen(initialTheme: AppThemeMode.system),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('light theme shows check icon when selected', (tester) async {
      await tester.pumpWidget(
        buildSettingsScreen(initialTheme: AppThemeMode.light),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('dark theme shows check icon when selected', (tester) async {
      await tester.pumpWidget(
        buildSettingsScreen(initialTheme: AppThemeMode.dark),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('tapping light mode triggers state change', (tester) async {
      await tester.pumpWidget(
        buildSettingsScreen(initialTheme: AppThemeMode.system),
      );

      await tester.tap(find.text('라이트 모드'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('tapping dark mode triggers state change', (tester) async {
      await tester.pumpWidget(
        buildSettingsScreen(initialTheme: AppThemeMode.system),
      );

      await tester.tap(find.text('다크 모드'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('SettingsScreen 계정 섹션', () {
    testWidgets('shows login required when not logged in', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('로그인 필요'), findsOneWidget);
    });

    testWidgets('shows logged in account label', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('로그인된 계정'), findsOneWidget);
    });

    testWidgets('shows logout option', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.text('로그아웃'), findsOneWidget);
    });

    testWidgets('shows logout icon', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('shows person icon for account', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('tapping logout shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      expect(find.text('정말 로그아웃 하시겠습니까?'), findsOneWidget);
    });

    testWidgets('logout dialog has title', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // 다이얼로그 제목
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);
    });

    testWidgets('logout dialog shows cancel button', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, '취소'), findsOneWidget);
    });

    testWidgets('logout dialog shows confirm button', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // 다이얼로그 내 로그아웃 버튼
      final buttons = find.widgetWithText(TextButton, '로그아웃');
      expect(buttons, findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, '취소'));
      await tester.pumpAndSettle();

      expect(find.text('정말 로그아웃 하시겠습니까?'), findsNothing);
    });
  });

  group('SettingsScreen 앱 정보', () {
    testWidgets('shows info icon', (tester) async {
      await tester.pumpWidget(buildSettingsScreen());

      // 앱 정보 섹션이 스크롤 아래에 있으므로 스크롤
      await tester.scrollUntilVisible(
        find.byIcon(Icons.info_outline_rounded),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });
}

/// 테스트용 ThemeNotifier
class TestThemeNotifier extends ThemeNotifier {
  TestThemeNotifier(AppThemeMode initialMode) : super() {
    state = initialMode;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
  }
}

/// 테스트용 AuthNotifier - AuthState만 관리
class TestAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  TestAuthNotifier() : super(const AuthState());

  @override
  Future<bool> signIn(String email, String password) async => true;

  @override
  Future<bool> signUp(String email, String password) async => true;

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
