import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/auth_service.dart';
import '../core/supabase.dart';

/// 인증 서비스 프로바이더
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// 인증 상태
class AuthState {
  final User? user;
  final Session? session;
  final bool isLoading;
  final String? errorMessage;
  final bool signUpCompleted; // 회원가입 완료 상태 (완료 화면 표시용)

  const AuthState({
    this.user,
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.signUpCompleted = false,
  });

  bool get isAuthenticated => user != null && !signUpCompleted;

  AuthState copyWith({
    User? user,
    Session? session,
    bool? isLoading,
    String? errorMessage,
    bool? signUpCompleted,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      signUpCompleted: signUpCompleted ?? this.signUpCompleted,
    );
  }
}

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    // 현재 세션 확인
    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;

    state = AuthState(
      user: user,
      session: session,
      isLoading: false,
    );

    // 인증 상태 변경 리스닝
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      // 회원가입 완료 상태는 유지 (완료 화면 표시 중일 때)
      final keepSignUpCompleted = state.signUpCompleted && data.session?.user != null;

      // 현재 로딩 중이면 무시 (signIn/signUp 메서드에서 처리 중)
      if (state.isLoading) return;

      // 이미 같은 사용자라면 무시 (중복 업데이트 방지)
      if (state.user?.id == data.session?.user?.id &&
          state.session?.accessToken == data.session?.accessToken) {
        return;
      }

      state = AuthState(
        user: data.session?.user,
        session: data.session,
        isLoading: false,
        signUpCompleted: keepSignUpCompleted,
      );
    });
  }

  /// 회원가입
  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 회원가입 완료 상태로 설정 (바로 홈으로 가지 않고 완료 화면 표시)
        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
          signUpCompleted: true, // 완료 화면 표시를 위한 플래그
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
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 회원가입 완료 후 로그인 화면으로 전환
  void goToLogin() {
    // 로그아웃하고 로그인 화면으로 이동
    _authService.signOut();
    state = const AuthState();
  }

  /// 회원가입 완료 후 바로 앱 사용 (이미 로그인 상태)
  void continueToApp() {
    state = state.copyWith(signUpCompleted: false);
  }

  /// 로그인
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
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// 인증 상태 프로바이더
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
