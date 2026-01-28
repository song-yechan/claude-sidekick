/// BookScribe 디자인 시스템
///
/// Vercel Design Guidelines + UI Skills 기반 디자인 시스템입니다.
/// 일관된 UI를 위한 토큰, 컴포넌트 스타일, 애니메이션 규칙을 정의합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// =============================================================================
// 애니메이션 토큰
// =============================================================================

/// 애니메이션 지속 시간 (200ms 이하 원칙)
abstract final class DSAnimations {
  /// 빠른 피드백 (탭, 호버)
  static const Duration fast = Duration(milliseconds: 100);

  /// 기본 전환
  static const Duration normal = Duration(milliseconds: 150);

  /// 느린 전환 (모달, 페이지)
  static const Duration slow = Duration(milliseconds: 200);

  /// 기본 커브
  static const Curve defaultCurve = Curves.easeOut;

  /// 진입 커브
  static const Curve enterCurve = Curves.easeOutCubic;

  /// 퇴장 커브
  static const Curve exitCurve = Curves.easeInCubic;
}

// =============================================================================
// 그림자 시스템 (두 계층: ambient + direct)
// =============================================================================

/// 두 계층 그림자 (주변광 + 직광)
abstract final class DSShadows {
  /// 낮은 고도 (카드 기본)
  static List<BoxShadow> low(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      // Ambient (주변광)
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.3 : 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      // Direct (직광)
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.2 : 0.08),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// 중간 고도 (호버, 포커스)
  static List<BoxShadow> medium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.4 : 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.25 : 0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// 높은 고도 (모달, 드롭다운)
  static List<BoxShadow> high(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.5 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.3 : 0.12),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

// =============================================================================
// 타이포그래피 확장
// =============================================================================

/// 숫자 전용 스타일 (tabular figures)
extension DSTypography on TextStyle {
  /// 테이블 숫자 (고정폭 숫자)
  TextStyle get tabularFigures => copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 숫자 + 볼드
  TextStyle get tabularBold => copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.bold,
      );
}

// =============================================================================
// 상호작용 피드백
// =============================================================================

/// 터치 피드백 래퍼
class DSInteractive extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final BorderRadius? borderRadius;

  const DSInteractive({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.borderRadius,
  });

  @override
  State<DSInteractive> createState() => _DSInteractiveState();
}

class _DSInteractiveState extends State<DSInteractive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: DSAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // prefers-reduced-motion 존중
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _onPressStart() : null,
      onTapUp: widget.enabled ? (_) => _onPressEnd() : null,
      onTapCancel: widget.enabled ? _onPressEnd : null,
      onTap: widget.enabled ? _onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: reduceMotion
          ? widget.child
          : AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
              child: widget.child,
            ),
    );
  }

  void _onPressStart() {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onPressEnd() {
    _controller.reverse();
  }

  void _onTap() {
    widget.onTap?.call();
  }
}

// =============================================================================
// 스켈레톤 로딩
// =============================================================================

/// 스켈레톤 로딩 위젯
class DSSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const DSSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// 원형 스켈레톤
  const DSSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null;

  @override
  State<DSSkeleton> createState() => _DSSkeletonState();
}

class _DSSkeletonState extends State<DSSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    // prefers-reduced-motion 존중
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          shape: widget.width == widget.height && widget.borderRadius == null
              ? BoxShape.circle
              : BoxShape.rectangle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            shape: widget.width == widget.height && widget.borderRadius == null
                ? BoxShape.circle
                : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// 빈 상태 위젯
// =============================================================================

/// 빈 상태 위젯 (하나의 명확한 CTA 포함)
class DSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// 애니메이션 래퍼 (등장/퇴장)
// =============================================================================

/// 등장 애니메이션 (fade + scale)
class DSFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const DSFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = DSAnimations.normal,
  });

  @override
  State<DSFadeIn> createState() => _DSFadeInState();
}

class _DSFadeInState extends State<DSFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: DSAnimations.enterCurve,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSAnimations.enterCurve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // prefers-reduced-motion 존중
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// =============================================================================
// 접근성 헬퍼
// =============================================================================

/// 접근성 래퍼
class DSAccessible extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isHeader;
  final VoidCallback? onTap;

  const DSAccessible({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      child: child,
    );
  }
}
