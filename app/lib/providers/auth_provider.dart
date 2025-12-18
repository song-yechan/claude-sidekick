import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  const AuthState({
    this.user,
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    Session? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<AuthState>? _authSubscription;

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
    supabase.auth.onAuthStateChange.listen((data) {
      state = AuthState(
        user: data.session?.user,
        session: data.session,
        isLoading: false,
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
        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
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
