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
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // 로고 애니메이션
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // 텍스트 타이핑 애니메이션
  late AnimationController _textController;
  late Animation<int> _textLength;

  // 로딩 인디케이터 애니메이션
  late AnimationController _loadingController;
  late Animation<double> _loadingOpacity;

  final String _appName = 'BookScribe';
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // 로고 애니메이션 (0.8s)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // 텍스트 타이핑 애니메이션 (0.6s, 로고 후 시작)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textLength = IntTween(begin: 0, end: _appName.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // 로딩 인디케이터 페이드인 (0.4s, 텍스트 후 시작)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() async {
    // 로고 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _logoController.forward();

    // 텍스트 애니메이션 시작 (로고 후)
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _textController.forward();

    // 로딩 인디케이터 시작 (텍스트 후)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _loadingController.forward();
  }

  void _navigateToNextScreen() {
    if (_navigationTriggered || !mounted) return;
    _navigationTriggered = true;

    final authState = ref.read(authProvider);
    final onboardingState = ref.read(onboardingProvider);

    String destination;
    if (!authState.isAuthenticated) {
      destination = '/auth';
    } else if (!onboardingState.isCompleted) {
      destination = '/onboarding';
    } else {
      destination = '/home';
    }

    // 페이드 아웃 후 이동
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
      // 애니메이션이 어느 정도 진행된 후 이동 (최소 1.2초)
      Future.delayed(const Duration(milliseconds: 1200), _navigateToNextScreen);
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 60,
                      color: context.colors.primary,
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

/// 깜빡이는 커서 위젯
class _BlinkingCursor extends StatefulWidget {
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
