/// 인증 상태 관리 Provider
///
/// 이 파일은 앱의 인증(로그인/회원가입/로그아웃) 상태를 관리합니다.
/// Supabase Auth를 사용하여 사용자 인증을 처리하고,
/// Riverpod StateNotifier 패턴으로 상태를 관리합니다.
///
/// 주요 기능:
/// - 이메일/비밀번호 로그인 및 회원가입
/// - 세션 상태 실시간 동기화
/// - 회원가입 완료 화면 플로우 관리
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../services/auth_service.dart';
import '../core/supabase.dart';

/// 인증 서비스 인스턴스를 제공하는 Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// 인증 상태를 나타내는 불변 클래스
///
/// 사용자의 인증 상태, 세션 정보, 로딩 상태 등을 포함합니다.
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

/// 인증 상태를 관리하는 StateNotifier
///
/// Supabase의 인증 이벤트를 구독하여 실시간으로 상태를 동기화하고,
/// 로그인/회원가입/로그아웃 작업을 수행합니다.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _init();
  }

  /// 초기화 메서드
  ///
  /// 앱 시작 시 현재 세션을 확인하고,
  /// Supabase 인증 상태 변경 이벤트를 구독합니다.
  void _init() {
    // 로컬에 저장된 세션이 있는지 확인
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

  /// 이메일/비밀번호로 회원가입을 수행합니다.
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 비밀번호 (최소 6자 이상)
  ///
  /// 성공 시 true를 반환하고, [signUpCompleted] 플래그를 설정하여
  /// 회원가입 완료 화면을 표시할 수 있도록 합니다.
  Future<bool> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('🔐 SignUp 시도: $email');
      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      print('🔐 SignUp 응답 - user: ${response.user?.id}, session: ${response.session?.accessToken != null}');

      if (response.user != null) {
        // 회원가입 완료 상태로 설정 (바로 홈으로 가지 않고 완료 화면 표시)
        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
          signUpCompleted: true, // 완료 화면 표시를 위한 플래그
        );
        print('🔐 SignUp 성공!');
        return true;
      } else {
        print('🔐 SignUp 실패 - user가 null');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '회원가입에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      print('🔐 SignUp 에러: $e');
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

  /// 이메일/비밀번호로 로그인을 수행합니다.
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 비밀번호
  ///
  /// 성공 시 true를 반환합니다. 로그인 후 약간의 딜레이를 주어
  /// Supabase 세션이 완전히 설정되도록 합니다.
  Future<bool> signIn(String email, String password) async {
    print('🔐 SignIn 시도: $email');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      print('🔐 SignIn 응답 - user: ${response.user?.id}, session: ${response.session?.accessToken != null}');

      if (response.user != null) {
        // 약간의 딜레이를 주어 Supabase 세션이 완전히 설정되도록 함
        await Future.delayed(const Duration(milliseconds: 100));

        state = AuthState(
          user: response.user,
          session: response.session,
          isLoading: false,
        );
        print('🔐 SignIn 성공! isAuthenticated: ${state.isAuthenticated}');
        return true;
      } else {
        print('🔐 SignIn 실패 - user가 null');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '로그인에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      print('🔐 SignIn 에러: $e');
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
