/// 스트릭 카드 위젯
///
/// 홈 화면에 표시되는 연속 독서 일수 카드입니다.
/// 현재 스트릭, 최장 기록, 오늘 활동 상태를 표시합니다.
///
/// 디자인 시스템 적용:
/// - 두 계층 그림자 (DSShadows)
/// - 스켈레톤 로딩 (DSSkeleton)
/// - 등장 애니메이션 (DSFadeIn)
/// - 숫자 tabular figures
/// - 접근성 (Semantics)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../models/streak.dart';
import '../../providers/streak_provider.dart';

/// 스트릭 카드 위젯
///
/// 홈 화면에서 사용자의 연속 독서 현황을 보여줍니다.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      loading: () => _StreakCardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) => DSFadeIn(
        child: _StreakCardContent(streak: streak),
      ),
    );
  }
}

/// 스켈레톤 로딩 카드
class _StreakCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.large),
        boxShadow: DSShadows.low(context),
      ),
      child: Row(
        children: [
          // 아이콘 스켈레톤
          DSSkeleton(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(AppShapes.medium),
          ),
          const SizedBox(width: AppSpacing.lg),
          // 텍스트 스켈레톤
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(
                  width: 120,
                  height: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.sm),
                DSSkeleton(
                  width: 180,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: AppSpacing.xs),
                DSSkeleton(
                  width: 100,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 스트릭 카드 콘텐츠
class _StreakCardContent extends StatelessWidget {
  final StreakData? streak;

  const _StreakCardContent({this.streak});

  @override
  Widget build(BuildContext context) {
    final currentStreak = streak?.currentStreak ?? 0;
    final longestStreak = streak?.longestStreak ?? 0;
    final isActiveToday = streak?.isActiveToday ?? false;
    final colors = Theme.of(context).colorScheme;

    // 빈 상태: 스트릭이 0이고 오늘 활동 없음
    if (currentStreak == 0 && !isActiveToday) {
      return _StreakCardEmpty();
    }

    return DSAccessible(
      label: context.l10n.streak_currentDays(currentStreak),
      hint: isActiveToday
          ? context.l10n.streak_todayDone
          : context.l10n.streak_todayPending,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isActiveToday
              ? colors.primaryContainer
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.large),
          boxShadow: DSShadows.low(context),
          border: Border.all(
            color: isActiveToday
                ? colors.primary.withValues(alpha: 0.2)
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 불꽃 아이콘 + 스트릭 숫자
            _StreakIcon(
              currentStreak: currentStreak,
              isActiveToday: isActiveToday,
            ),
            const SizedBox(width: AppSpacing.lg),

            // 텍스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 스트릭 타이틀
                  Text(
                    _getStreakTitle(context, currentStreak),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // 상태 메시지
                  Text(
                    _getStatusMessage(context, isActiveToday, currentStreak),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  // 최장 기록 (0보다 클 때만)
                  if (longestStreak > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.streak_longestRecord(longestStreak),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ).tabularFigures,
                    ),
                  ],
                ],
              ),
            ),

            // 오늘 활동 체크 표시
            if (isActiveToday) _TodayCompleteBadge(),
          ],
        ),
      ),
    );
  }

  String _getStreakTitle(BuildContext context, int currentStreak) {
    if (currentStreak == 0) {
      return context.l10n.streak_title;
    }
    return context.l10n.streak_currentDays(currentStreak);
  }

  String _getStatusMessage(
    BuildContext context,
    bool isActiveToday,
    int currentStreak,
  ) {
    if (isActiveToday) {
      return context.l10n.streak_todayDone;
    }
    if (currentStreak > 0) {
      return context.l10n.streak_todayPending;
    }
    return context.l10n.streak_startNew;
  }
}

/// 빈 상태 카드
class _StreakCardEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.large),
        boxShadow: DSShadows.low(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppShapes.medium),
            ),
            child: Icon(
              Icons.local_fire_department_outlined,
              size: 28,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.streak_title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.streak_startNew,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // CTA 버튼 (하나의 명확한 액션)
          FilledButton.tonal(
            onPressed: () => context.go('/search'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              minimumSize: const Size(44, 44), // 터치 타겟 최소 44px
            ),
            child: Text(context.l10n.common_start),
          ),
        ],
      ),
    );
  }
}

/// 스트릭 아이콘
class _StreakIcon extends StatelessWidget {
  final int currentStreak;
  final bool isActiveToday;

  const _StreakIcon({
    required this.currentStreak,
    required this.isActiveToday,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // 불꽃 색상 (스트릭 레벨에 따라)
    final Color iconColor;
    if (currentStreak >= 30) {
      iconColor = const Color(0xFFFF4500); // 빨간 불꽃 (30일+)
    } else if (currentStreak >= 7) {
      iconColor = const Color(0xFFFF6B35); // 오렌지 불꽃 (7일+)
    } else if (currentStreak > 0) {
      iconColor = const Color(0xFFFFB347); // 연한 오렌지 (1일+)
    } else {
      iconColor = colors.onSurfaceVariant;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: currentStreak > 0
            ? iconColor.withValues(alpha: 0.12)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppShapes.medium),
        boxShadow: currentStreak > 0
            ? [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            currentStreak > 0
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            size: 24,
            color: iconColor,
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: 2),
            Text(
              '$currentStreak',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ).tabularFigures,
            ),
          ],
        ],
      ),
    );
  }
}

/// 오늘 완료 배지
class _TodayCompleteBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        size: 20,
        color: colors.primary,
      ),
    );
  }
}
