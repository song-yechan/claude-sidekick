/// Mock AuthService
///
/// 테스트용 AuthService 모킹 클래스입니다.
/// 실제 Supabase Auth 호출 없이 테스트할 수 있도록 합니다.
library;

import 'dart:async';
import 'test_fixtures.dart';

/// 간단한 Mock User 클래스
class MockUser {
  final String id;
  final String email;
  final DateTime createdAt;

  MockUser({
    required this.id,
    required this.email,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// 간단한 Mock Session 클래스
class MockSession {
  final String accessToken;
  final String refreshToken;
  final MockUser user;
  final DateTime expiresAt;

  MockSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? DateTime.now().add(const Duration(hours: 1));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Mock Auth Response
class MockAuthResponse {
  final MockSession? session;
  final MockUser? user;

  MockAuthResponse({this.session, this.user});
}

/// Mock Auth State
enum MockAuthChangeEvent {
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
}

class MockAuthState {
  final MockAuthChangeEvent event;
  final MockSession? session;

  MockAuthState(this.event, this.session);
}

/// AuthService 인터페이스
abstract class IAuthService {
  Future<MockAuthResponse> signUp({
    required String email,
    required String password,
  });
  Future<MockAuthResponse> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<MockSession?> getSession();
  Stream<MockAuthState> get authStateChanges;
}

/// Mock AuthService
///
/// 테스트에서 사용할 AuthService 모킹 구현체입니다.
class MockAuthService implements IAuthService {
  /// 등록된 사용자 목록 (email -> password)
  final Map<String, String> _registeredUsers = {};

  /// 등록된 사용자 정보 (email -> MockUser)
  final Map<String, MockUser> _userInfo = {};

  /// 현재 세션
  MockSession? _currentSession;

  /// Auth 상태 스트림 컨트롤러
  final StreamController<MockAuthState> _authStateController =
      StreamController<MockAuthState>.broadcast();

  /// 에러 시뮬레이션용 플래그
  bool shouldThrowOnSignUp = false;
  bool shouldThrowOnSignIn = false;
  bool shouldThrowOnSignOut = false;
  String? customError;

  /// 지연 시뮬레이션 (ms)
  int delayMs = 0;

  MockAuthService() {
    // 기본 테스트 사용자 추가
    _registeredUsers[TestUsers.email1] = TestUsers.password;
    _userInfo[TestUsers.email1] = MockUser(
      id: TestUsers.userId1,
      email: TestUsers.email1,
    );
  }

  /// 상태 초기화
  void reset() {
    _registeredUsers.clear();
    _userInfo.clear();
    _currentSession = null;
    shouldThrowOnSignUp = false;
    shouldThrowOnSignIn = false;
    shouldThrowOnSignOut = false;
    customError = null;
    delayMs = 0;

    // 기본 테스트 사용자 재추가
    _registeredUsers[TestUsers.email1] = TestUsers.password;
    _userInfo[TestUsers.email1] = MockUser(
      id: TestUsers.userId1,
      email: TestUsers.email1,
    );
  }

  /// 현재 세션 반환 (테스트 검증용)
  MockSession? get currentSession => _currentSession;

  /// 등록된 사용자 수 (테스트 검증용)
  int get registeredUserCount => _registeredUsers.length;

  Future<void> _simulateDelay() async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  @override
  Future<MockAuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    if (shouldThrowOnSignUp) {
      throw Exception(customError ?? TestErrors.unknownError);
    }

    // 이메일 형식 검증
    if (!email.contains('@')) {
      throw Exception(TestErrors.invalidEmail);
    }

    // 비밀번호 길이 검증
    if (password.length < 6) {
      throw Exception(TestErrors.weakPassword);
    }

    // 이미 등록된 사용자 체크
    if (_registeredUsers.containsKey(email)) {
      throw Exception(TestErrors.userAlreadyExists);
    }

    // 새 사용자 등록
    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _registeredUsers[email] = password;
    _userInfo[email] = MockUser(id: userId, email: email);

    final user = _userInfo[email]!;

    // 회원가입 시 자동 로그인하지 않음 (이메일 인증 필요 가정)
    return MockAuthResponse(user: user);
  }

  @override
  Future<MockAuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    if (shouldThrowOnSignIn) {
      throw Exception(customError ?? TestErrors.unknownError);
    }

    // 등록되지 않은 사용자
    if (!_registeredUsers.containsKey(email)) {
      throw Exception(TestErrors.invalidCredentials);
    }

    // 비밀번호 불일치
    if (_registeredUsers[email] != password) {
      throw Exception(TestErrors.invalidCredentials);
    }

    final user = _userInfo[email]!;
    _currentSession = MockSession(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
      user: user,
    );

    _authStateController.add(MockAuthState(
      MockAuthChangeEvent.signedIn,
      _currentSession,
    ));

    return MockAuthResponse(session: _currentSession, user: user);
  }

  @override
  Future<void> signOut() async {
    await _simulateDelay();

    if (shouldThrowOnSignOut) {
      throw Exception(customError ?? TestErrors.unknownError);
    }

    _currentSession = null;
    _authStateController.add(MockAuthState(
      MockAuthChangeEvent.signedOut,
      null,
    ));
  }

  @override
  Future<MockSession?> getSession() async {
    await _simulateDelay();
    return _currentSession;
  }

  @override
  Stream<MockAuthState> get authStateChanges => _authStateController.stream;

  /// 리소스 정리
  void dispose() {
    _authStateController.close();
  }
}
