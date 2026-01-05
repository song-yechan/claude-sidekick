/// AuthService 테스트
///
/// MockAuthService를 사용하여 인증 서비스의 동작을 검증합니다.
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mocks.dart';

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  tearDown(() {
    authService.reset();
    authService.dispose();
  });

  group('signUp', () {
    test('새 사용자를 등록한다', () async {
      // Given
      const email = 'newuser@example.com';
      const password = 'password123';

      // When
      final response = await authService.signUp(
        email: email,
        password: password,
      );

      // Then
      expect(response.user, isNotNull);
      expect(response.user!.email, email);
      expect(authService.registeredUserCount, 2); // 기본 1명 + 새 1명
    });

    test('이미 등록된 이메일은 예외를 던진다', () async {
      // Given (TestUsers.email1은 이미 등록됨)

      // When & Then
      expect(
        () => authService.signUp(
          email: TestUsers.email1,
          password: TestUsers.password,
        ),
        throwsA(predicate((e) =>
            e.toString().contains(TestErrors.userAlreadyExists))),
      );
    });

    test('잘못된 이메일 형식은 예외를 던진다', () async {
      // When & Then
      expect(
        () => authService.signUp(
          email: 'invalid-email',
          password: 'password123',
        ),
        throwsA(predicate((e) =>
            e.toString().contains(TestErrors.invalidEmail))),
      );
    });

    test('짧은 비밀번호는 예외를 던진다', () async {
      // When & Then
      expect(
        () => authService.signUp(
          email: 'new@example.com',
          password: TestUsers.weakPassword,
        ),
        throwsA(predicate((e) =>
            e.toString().contains(TestErrors.weakPassword))),
      );
    });

    test('회원가입 후 자동 로그인되지 않는다', () async {
      // When
      await authService.signUp(
        email: 'new@example.com',
        password: 'password123',
      );

      // Then
      expect(authService.currentSession, isNull);
    });
  });

  group('signIn', () {
    test('등록된 사용자로 로그인한다', () async {
      // When
      final response = await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );

      // Then
      expect(response.session, isNotNull);
      expect(response.user, isNotNull);
      expect(response.user!.email, TestUsers.email1);
      expect(authService.currentSession, isNotNull);
    });

    test('잘못된 비밀번호는 예외를 던진다', () async {
      // When & Then
      expect(
        () => authService.signIn(
          email: TestUsers.email1,
          password: 'wrongpassword',
        ),
        throwsA(predicate((e) =>
            e.toString().contains(TestErrors.invalidCredentials))),
      );
    });

    test('등록되지 않은 이메일은 예외를 던진다', () async {
      // When & Then
      expect(
        () => authService.signIn(
          email: 'unknown@example.com',
          password: 'password123',
        ),
        throwsA(predicate((e) =>
            e.toString().contains(TestErrors.invalidCredentials))),
      );
    });

    test('로그인 시 auth state 이벤트가 발생한다', () async {
      // Given
      final events = <MockAuthState>[];
      authService.authStateChanges.listen(events.add);

      // When
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );

      // Then
      await Future.delayed(const Duration(milliseconds: 50));
      expect(events.length, 1);
      expect(events.first.event, MockAuthChangeEvent.signedIn);
    });
  });

  group('signOut', () {
    test('로그아웃한다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );
      expect(authService.currentSession, isNotNull);

      // When
      await authService.signOut();

      // Then
      expect(authService.currentSession, isNull);
    });

    test('로그아웃 시 auth state 이벤트가 발생한다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );
      final events = <MockAuthState>[];
      authService.authStateChanges.listen(events.add);

      // When
      await authService.signOut();

      // Then
      await Future.delayed(const Duration(milliseconds: 50));
      expect(events.any((e) => e.event == MockAuthChangeEvent.signedOut), true);
    });
  });

  group('getSession', () {
    test('로그인 상태에서 세션을 반환한다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );

      // When
      final session = await authService.getSession();

      // Then
      expect(session, isNotNull);
      expect(session!.user.email, TestUsers.email1);
    });

    test('로그아웃 상태에서 null을 반환한다', () async {
      // When
      final session = await authService.getSession();

      // Then
      expect(session, isNull);
    });
  });

  group('에러 시뮬레이션', () {
    test('signUp 에러를 시뮬레이션할 수 있다', () async {
      // Given
      authService.shouldThrowOnSignUp = true;
      authService.customError = 'Custom signup error';

      // When & Then
      expect(
        () => authService.signUp(
          email: 'new@example.com',
          password: 'password123',
        ),
        throwsA(predicate((e) => e.toString().contains('Custom signup error'))),
      );
    });

    test('signIn 에러를 시뮬레이션할 수 있다', () async {
      // Given
      authService.shouldThrowOnSignIn = true;
      authService.customError = 'Custom signin error';

      // When & Then
      expect(
        () => authService.signIn(
          email: TestUsers.email1,
          password: TestUsers.password,
        ),
        throwsA(predicate((e) => e.toString().contains('Custom signin error'))),
      );
    });
  });

  group('전체 인증 플로우', () {
    test('회원가입 -> 로그인 -> 로그아웃 플로우', () async {
      // 1. 회원가입
      final signUpResponse = await authService.signUp(
        email: 'newuser@example.com',
        password: 'password123',
      );
      expect(signUpResponse.user, isNotNull);
      expect(authService.currentSession, isNull); // 아직 로그인 안 됨

      // 2. 로그인
      final signInResponse = await authService.signIn(
        email: 'newuser@example.com',
        password: 'password123',
      );
      expect(signInResponse.session, isNotNull);
      expect(authService.currentSession, isNotNull);

      // 3. 로그아웃
      await authService.signOut();
      expect(authService.currentSession, isNull);
    });
  });

  group('deleteAccount', () {
    test('로그인 상태에서 계정을 삭제한다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );
      expect(authService.currentSession, isNotNull);
      final initialUserCount = authService.registeredUserCount;

      // When
      await authService.deleteAccount();

      // Then
      expect(authService.currentSession, isNull);
      expect(authService.registeredUserCount, initialUserCount - 1);
    });

    test('로그아웃 상태에서 계정 삭제 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => authService.deleteAccount(),
        throwsA(predicate((e) => e.toString().contains('No active session'))),
      );
    });

    test('계정 삭제 후 동일 이메일로 재가입 가능하다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );

      // When - 계정 삭제
      await authService.deleteAccount();

      // Then - 동일 이메일로 재가입 가능
      final response = await authService.signUp(
        email: TestUsers.email1,
        password: 'newpassword123',
      );
      expect(response.user, isNotNull);
    });

    test('계정 삭제 에러를 시뮬레이션할 수 있다', () async {
      // Given
      await authService.signIn(
        email: TestUsers.email1,
        password: TestUsers.password,
      );
      authService.shouldThrowOnDeleteAccount = true;
      authService.customError = 'Delete account failed';

      // When & Then
      expect(
        () => authService.deleteAccount(),
        throwsA(predicate((e) => e.toString().contains('Delete account failed'))),
      );
    });
  });
}
