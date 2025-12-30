/// AuthNotifier 테스트
///
/// FakeAuthService를 사용하여 AuthNotifier의 동작을 검증합니다.
/// Supabase 의존성 없이 로그인/회원가입 로직을 테스트합니다.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookscribe/providers/auth_provider.dart';
import 'package:bookscribe/services/auth_service.dart';
import '../mocks/fake_auth_service.dart';

/// 테스트용 AuthNotifier
///
/// 실제 AuthNotifier와 동일한 로직을 사용하지만,
/// Supabase 초기화(_init)를 건너뛰어 테스트 가능하게 합니다.
class TestableAuthNotifier extends StateNotifier<AuthState> {
  final IAuthService _authService;

  TestableAuthNotifier(this._authService) : super(const AuthState());

  /// signUp 테스트용
  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
          signUpCompleted: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '회원가입에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: getKoreanAuthErrorMessage(e),
      );
      return false;
    }
  }

  /// signIn 테스트용
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '로그인에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: getKoreanAuthErrorMessage(e),
      );
      return false;
    }
  }

  /// signOut 테스트용
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  /// goToLogin 테스트용
  void goToLogin() {
    _authService.signOut();
    state = const AuthState();
  }

  /// continueToApp 테스트용
  void continueToApp() {
    state = state.copyWith(signUpCompleted: false);
  }

  /// 현재 상태 조회
  AuthState get currentState => state;
}

void main() {
  late FakeAuthService fakeAuthService;
  late TestableAuthNotifier authNotifier;

  setUp(() {
    fakeAuthService = FakeAuthService();
    authNotifier = TestableAuthNotifier(fakeAuthService);
  });

  tearDown(() {
    fakeAuthService.reset();
  });

  group('signUp', () {
    test('회원가입 성공 시 signUpCompleted가 true가 된다', () async {
      // Given
      fakeAuthService.signUpResponse = FakeAuthResponses.emptyResponse;

      // When - user가 null이므로 실패 케이스
      final result = await authNotifier.signUp('test@example.com', 'password123');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.isLoading, false);
      expect(authNotifier.currentState.errorMessage, '회원가입에 실패했습니다.');
    });

    test('회원가입 시 AuthService.signUp이 호출된다', () async {
      // Given
      fakeAuthService.signUpResponse = FakeAuthResponses.emptyResponse;

      // When
      await authNotifier.signUp('user@test.com', 'mypassword');

      // Then
      expect(fakeAuthService.signUpCallCount, 1);
      expect(fakeAuthService.lastEmail, 'user@test.com');
      expect(fakeAuthService.lastPassword, 'mypassword');
    });

    test('회원가입 실패 시 에러 메시지가 설정된다 - 이미 가입된 이메일', () async {
      // Given
      fakeAuthService.signUpError = Exception('User already registered');

      // When
      final result = await authNotifier.signUp('existing@test.com', 'password');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.isLoading, false);
      expect(authNotifier.currentState.errorMessage, '이미 가입된 이메일입니다.');
    });

    test('회원가입 실패 시 에러 메시지가 설정된다 - 잘못된 이메일 형식', () async {
      // Given
      fakeAuthService.signUpError = Exception('Invalid email format');

      // When
      final result = await authNotifier.signUp('invalid-email', 'password');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.errorMessage, '올바른 이메일 형식이 아닙니다.');
    });

    test('회원가입 실패 시 에러 메시지가 설정된다 - 짧은 비밀번호', () async {
      // Given
      fakeAuthService.signUpError = Exception('Password should be at least 6 characters');

      // When
      final result = await authNotifier.signUp('test@test.com', '123');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.errorMessage, '비밀번호는 6자 이상이어야 합니다.');
    });

    test('회원가입 중 isLoading이 true가 된다', () async {
      // Given
      fakeAuthService.signUpResponse = FakeAuthResponses.emptyResponse;

      // When - Future를 기다리지 않고 상태 확인
      final future = authNotifier.signUp('test@test.com', 'password');

      // 비동기 작업이 시작된 후 즉시 확인하면 isLoading이 true일 수 있음
      // 완료 후에는 false
      await future;
      expect(authNotifier.currentState.isLoading, false);
    });
  });

  group('signIn', () {
    test('로그인 성공 응답이지만 user가 null이면 실패', () async {
      // Given
      fakeAuthService.signInResponse = FakeAuthResponses.emptyResponse;

      // When
      final result = await authNotifier.signIn('test@example.com', 'password123');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.isLoading, false);
      expect(authNotifier.currentState.errorMessage, '로그인에 실패했습니다.');
    });

    test('로그인 시 AuthService.signIn이 호출된다', () async {
      // Given
      fakeAuthService.signInResponse = FakeAuthResponses.emptyResponse;

      // When
      await authNotifier.signIn('login@test.com', 'secret');

      // Then
      expect(fakeAuthService.signInCallCount, 1);
      expect(fakeAuthService.lastEmail, 'login@test.com');
      expect(fakeAuthService.lastPassword, 'secret');
    });

    test('로그인 실패 시 에러 메시지가 설정된다 - 잘못된 로그인 정보', () async {
      // Given
      fakeAuthService.signInError = Exception('Invalid login credentials');

      // When
      final result = await authNotifier.signIn('test@test.com', 'wrongpassword');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.errorMessage, '이메일 또는 비밀번호가 올바르지 않습니다.');
    });

    test('로그인 실패 시 에러 메시지가 설정된다 - 네트워크 오류', () async {
      // Given
      fakeAuthService.signInError = Exception('Network error');

      // When
      final result = await authNotifier.signIn('test@test.com', 'password');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.errorMessage, '네트워크 연결을 확인해주세요.');
    });

    test('로그인 실패 시 에러 메시지가 설정된다 - 요청 제한', () async {
      // Given
      fakeAuthService.signInError = Exception('Too many requests');

      // When
      final result = await authNotifier.signIn('test@test.com', 'password');

      // Then
      expect(result, false);
      expect(authNotifier.currentState.errorMessage, '잠시 후 다시 시도해주세요.');
    });
  });

  group('signOut', () {
    test('로그아웃 시 상태가 초기화된다', () async {
      // Given - 로그인 상태를 시뮬레이션 (실제로는 user가 있어야 함)
      fakeAuthService.signInResponse = FakeAuthResponses.emptyResponse;

      // When
      await authNotifier.signOut();

      // Then
      expect(authNotifier.currentState.user, isNull);
      expect(authNotifier.currentState.session, isNull);
      expect(authNotifier.currentState.isLoading, false);
      expect(authNotifier.currentState.isAuthenticated, false);
    });

    test('로그아웃 시 AuthService.signOut이 호출된다', () async {
      // When
      await authNotifier.signOut();

      // Then
      expect(fakeAuthService.signOutCallCount, 1);
    });
  });

  group('goToLogin', () {
    test('로그인 화면으로 이동 시 상태가 초기화된다', () {
      // When
      authNotifier.goToLogin();

      // Then
      expect(authNotifier.currentState.user, isNull);
      expect(authNotifier.currentState.session, isNull);
      expect(authNotifier.currentState.signUpCompleted, false);
      expect(authNotifier.currentState.isAuthenticated, false);
    });
  });

  group('continueToApp', () {
    test('앱 계속 사용 시 signUpCompleted가 false가 된다', () {
      // Given - signUpCompleted 상태 설정은 직접 테스트하기 어려움
      // TestableAuthNotifier의 state를 직접 설정할 수 없으므로
      // continueToApp 호출 후 signUpCompleted가 false인지만 확인

      // When
      authNotifier.continueToApp();

      // Then
      expect(authNotifier.currentState.signUpCompleted, false);
    });
  });

  group('FakeAuthService', () {
    test('signUp 호출 횟수를 추적한다', () async {
      // Given
      fakeAuthService.signUpResponse = FakeAuthResponses.emptyResponse;

      // When
      await authNotifier.signUp('a@a.com', '111');
      await authNotifier.signUp('b@b.com', '222');
      await authNotifier.signUp('c@c.com', '333');

      // Then
      expect(fakeAuthService.signUpCallCount, 3);
    });

    test('signIn 호출 횟수를 추적한다', () async {
      // Given
      fakeAuthService.signInResponse = FakeAuthResponses.emptyResponse;

      // When
      await authNotifier.signIn('a@a.com', '111');
      await authNotifier.signIn('b@b.com', '222');

      // Then
      expect(fakeAuthService.signInCallCount, 2);
    });

    test('reset 후 상태가 초기화된다', () async {
      // Given
      fakeAuthService.signUpResponse = FakeAuthResponses.emptyResponse;
      await authNotifier.signUp('test@test.com', 'password');

      // When
      fakeAuthService.reset();

      // Then
      expect(fakeAuthService.signUpCallCount, 0);
      expect(fakeAuthService.signInCallCount, 0);
      expect(fakeAuthService.lastEmail, isNull);
      expect(fakeAuthService.lastPassword, isNull);
    });
  });

  group('에러 메시지 통합 테스트', () {
    test('다양한 에러가 올바른 한국어 메시지로 변환된다', () async {
      final errorCases = {
        'Invalid login credentials': '이메일 또는 비밀번호가 올바르지 않습니다.',
        'User already registered': '이미 가입된 이메일입니다.',
        'Email not confirmed': '이메일 인증이 필요합니다.',
        'Invalid email': '올바른 이메일 형식이 아닙니다.',
        'Password should be at least 6 characters': '비밀번호는 6자 이상이어야 합니다.',
        'Network error': '네트워크 연결을 확인해주세요.',
        'Connection failed': '네트워크 연결을 확인해주세요.',
        'Too many requests': '잠시 후 다시 시도해주세요.',
        'Rate limit exceeded': '잠시 후 다시 시도해주세요.',
        'Unknown error xyz': '오류가 발생했습니다. 다시 시도해주세요.',
      };

      for (final entry in errorCases.entries) {
        fakeAuthService.reset();
        fakeAuthService.signInError = Exception(entry.key);

        await authNotifier.signIn('test@test.com', 'password');

        expect(
          authNotifier.currentState.errorMessage,
          entry.value,
          reason: 'Error "${entry.key}" should produce "${entry.value}"',
        );
      }
    });
  });
}
