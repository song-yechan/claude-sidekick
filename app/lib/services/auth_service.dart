/// 인증 서비스
///
/// Supabase Auth를 사용하여 사용자 인증 관련 작업을 처리합니다.
/// 회원가입, 로그인, 로그아웃, 세션 관리 기능을 제공합니다.
///
/// 이 서비스는 AuthProvider에서 사용되며, 직접 UI에서 호출하지 않습니다.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase.dart';

/// AuthService 인터페이스
///
/// 테스트에서 Mock 구현체를 사용할 수 있도록 인터페이스를 정의합니다.
abstract class IAuthService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<Session?> getSession();
}

/// Supabase 인증 기능을 래핑하는 서비스 클래스
///
/// 인증 관련 Supabase API 호출을 캡슐화합니다.
class AuthService implements IAuthService {
  /// 이메일/비밀번호로 회원가입을 수행합니다.
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 비밀번호 (최소 6자 이상)
  ///
  /// 반환값: 회원가입 결과를 담은 AuthResponse
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// 이메일/비밀번호로 로그인을 수행합니다.
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 비밀번호
  ///
  /// 반환값: 로그인 결과를 담은 AuthResponse
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 현재 세션을 종료하고 로그아웃합니다.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// 현재 저장된 세션 정보를 가져옵니다.
  ///
  /// 반환값: 현재 세션 또는 null (로그인되지 않은 경우)
  Future<Session?> getSession() async {
    return supabase.auth.currentSession;
  }

  /// 인증 상태 변경을 실시간으로 구독할 수 있는 스트림입니다.
  ///
  /// 로그인/로그아웃/토큰 갱신 등의 이벤트를 수신합니다.
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }
}
