import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase.dart';

class AuthService {
  /// 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// 현재 세션 가져오기
  Future<Session?> getSession() async {
    return supabase.auth.currentSession;
  }

  /// 인증 상태 변경 스트림
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }
}
