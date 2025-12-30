/// Fake AuthService for testing
///
/// AuthNotifier 테스트를 위한 Fake 구현체입니다.
/// 실제 Supabase 호출 없이 다양한 시나리오를 테스트할 수 있습니다.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bookscribe/services/auth_service.dart';

/// 테스트용 Fake AuthService
///
/// signUp, signIn 결과를 제어할 수 있으며,
/// 에러 시뮬레이션도 가능합니다.
class FakeAuthService implements IAuthService {
  /// signUp 성공 시 반환할 응답 (null이면 에러 발생)
  AuthResponse? signUpResponse;

  /// signIn 성공 시 반환할 응답 (null이면 에러 발생)
  AuthResponse? signInResponse;

  /// signUp 호출 시 발생시킬 에러
  Exception? signUpError;

  /// signIn 호출 시 발생시킬 에러
  Exception? signInError;

  /// signOut 호출 시 발생시킬 에러
  Exception? signOutError;

  /// 각 메서드 호출 횟수 추적
  int signUpCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  /// 마지막으로 전달된 credentials
  String? lastEmail;
  String? lastPassword;

  FakeAuthService();

  void reset() {
    signUpResponse = null;
    signInResponse = null;
    signUpError = null;
    signInError = null;
    signOutError = null;
    signUpCallCount = 0;
    signInCallCount = 0;
    signOutCallCount = 0;
    lastEmail = null;
    lastPassword = null;
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    lastEmail = email;
    lastPassword = password;

    if (signUpError != null) {
      throw signUpError!;
    }

    if (signUpResponse != null) {
      return signUpResponse!;
    }

    throw Exception('FakeAuthService: signUpResponse not configured');
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastEmail = email;
    lastPassword = password;

    if (signInError != null) {
      throw signInError!;
    }

    if (signInResponse != null) {
      return signInResponse!;
    }

    throw Exception('FakeAuthService: signInResponse not configured');
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;

    if (signOutError != null) {
      throw signOutError!;
    }
  }

  @override
  Future<Session?> getSession() async {
    return null;
  }
}

/// 테스트용 AuthResponse 생성 헬퍼
///
/// Supabase AuthResponse는 직접 생성이 어려우므로,
/// 테스트에서는 주로 에러 케이스를 테스트합니다.
/// 성공 케이스는 통합 테스트에서 다룹니다.
class FakeAuthResponses {
  /// user가 null인 응답 (실패 케이스)
  static AuthResponse get emptyResponse => AuthResponse(
        user: null,
        session: null,
      );
}
