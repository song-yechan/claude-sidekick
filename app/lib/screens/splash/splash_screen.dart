import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';

/// 인터랙티브 스플래시 화면
///
/// 앱 시작 시 로고 애니메이션과 타이핑 효과를 보여주고,
/// 인증 상태 확인 후 적절한 화면으로 이동합니다.
///
/// ## 애니메이션 시퀀스
/// 1. 로고 스케일/페이드 애니메이션 (0.2s 딜레이 후 1.2s)
/// 2. 앱 이름 타이핑 애니메이션 (로고 후 0.8s 딜레이, 1s 동안)
/// 3. 로딩 인디케이터 페이드인 (텍스트 후 0.7s 딜레이, 0.5s)
///
/// ## 네비게이션 로직
/// - 최소 2.5초 대기 후 인증/온보딩 상태에 따라 이동
/// - 미인증: `/auth` → 인증 미완료: `/onboarding` → 완료: `/home`
///
/// ## 사용된 에셋
/// - `assets/book-scanner.png`: 앱 로고 이미지 (1024x1024)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────
  // 애니메이션 컨트롤러 및 애니메이션 객체
  // ─────────────────────────────────────────────────────────────────

  /// 로고 애니메이션 컨트롤러 (스케일 + 페이드)
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  /// 앱 이름 타이핑 애니메이션 컨트롤러
  late AnimationController _textController;
  late Animation<int> _textLength;

  /// 로딩 인디케이터 페이드인 컨트롤러
  late AnimationController _loadingController;
  late Animation<double> _loadingOpacity;

  // ─────────────────────────────────────────────────────────────────
  // 상태 변수
  // ─────────────────────────────────────────────────────────────────

  /// 타이핑 애니메이션에 사용될 앱 이름
  final String _appName = 'BookScribe';

  /// 중복 네비게이션 방지 플래그
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  /// 모든 애니메이션 컨트롤러와 트윈을 초기화합니다.
  ///
  /// 각 애니메이션은 순차적으로 실행되도록 설계되어 있으며,
  /// [_startAnimations]에서 딜레이를 통해 시퀀스를 제어합니다.
  void _initAnimations() {
    // 로고 애니메이션 (1.2s) - easeOutBack으로 살짝 튕기는 효과
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // 텍스트 타이핑 애니메이션 (1s) - 한 글자씩 나타나는 효과
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textLength = IntTween(begin: 0, end: _appName.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // 로딩 인디케이터 페이드인 (0.5s)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
    );
  }

  /// 애니메이션 시퀀스를 시작합니다.
  ///
  /// 각 애니메이션은 딜레이를 두고 순차적으로 시작됩니다:
  /// - 0.2s 후: 로고 애니메이션
  /// - 1.0s 후: 텍스트 타이핑 애니메이션 (0.2 + 0.8)
  /// - 1.7s 후: 로딩 인디케이터 (0.2 + 0.8 + 0.7)
  void _startAnimations() async {
    // 초기 딜레이 후 로고 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();

    // 로고 애니메이션 진행 중 텍스트 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();

    // 텍스트 완료 전 로딩 인디케이터 표시
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) _loadingController.forward();
  }

  /// 인증 상태에 따라 적절한 화면으로 이동합니다.
  ///
  /// 이동 우선순위:
  /// 1. 미인증 → `/auth` (로그인/회원가입)
  /// 2. 온보딩 미완료 → `/onboarding`
  /// 3. 모두 완료 → `/home`
  ///
  /// [_navigationTriggered] 플래그로 중복 호출을 방지합니다.
  void _navigateToNextScreen() {
    if (_navigationTriggered || !mounted) return;
    _navigationTriggered = true;

    final authState = ref.read(authProvider);
    final onboardingState = ref.read(onboardingProvider);

    // 인증 상태에 따른 목적지 결정
    String destination;
    if (!authState.isAuthenticated) {
      destination = '/auth';
    } else if (!onboardingState.isCompleted) {
      destination = '/onboarding';
    } else {
      destination = '/home';
    }

    // 자연스러운 전환을 위해 약간의 딜레이 후 이동
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        context.go(destination);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 인증 상태 감시
    final authState = ref.watch(authProvider);
    final onboardingState = ref.watch(onboardingProvider);

    // 인증 로딩 완료 시 네비게이션
    if (!authState.isLoading && !onboardingState.isLoading) {
      // 애니메이션이 어느 정도 진행된 후 이동 (최소 2.5초)
      Future.delayed(const Duration(milliseconds: 2500), _navigateToNextScreen);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // 로고 애니메이션
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/book-scanner.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 앱 이름 타이핑 애니메이션
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                final displayText = _appName.substring(0, _textLength.value);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurface,
                        letterSpacing: 1.2,
                      ),
                    ),
                    // 커서 깜빡임 효과
                    if (_textLength.value < _appName.length)
                      _BlinkingCursor(color: context.colors.primary),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),

            // 서브타이틀
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => Opacity(
                opacity: _textController.value,
                child: Text(
                  '책 속 문장을 수집하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // 로딩 인디케이터
            AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) => Opacity(
                opacity: _loadingOpacity.value,
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '준비 중...',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

/// 타이핑 효과에 사용되는 깜빡이는 커서 위젯
///
/// 앱 이름 타이핑 애니메이션 중 텍스트 끝에 표시되는 커서입니다.
/// 500ms 주기로 페이드 인/아웃을 반복합니다.
class _BlinkingCursor extends StatefulWidget {
  /// 커서 색상 (일반적으로 primary 색상)
  final Color color;

  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 무한 반복되는 페이드 애니메이션 (500ms 주기)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _controller.value,
        child: Container(
          width: 3,
          height: 32,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }
}
