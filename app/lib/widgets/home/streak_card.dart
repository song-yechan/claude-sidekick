/// 스트릭 카드 위젯
///
/// 홈 화면에 표시되는 연속 독서 일수 카드입니다.
/// 현재 스트릭, 최장 기록, 오늘 활동 상태를 표시합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      loading: () => _buildLoadingCard(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) => _buildStreakCard(context, streak),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceContainer,
        borderRadius: BorderRadius.circular(AppShapes.large),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, StreakData? streak) {
    final currentStreak = streak?.currentStreak ?? 0;
    final longestStreak = streak?.longestStreak ?? 0;
    final isActiveToday = streak?.isActiveToday ?? false;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActiveToday
              ? [
                  context.colors.primaryContainer,
                  context.colors.primaryContainer.withValues(alpha: 0.7),
                ]
              : [
                  context.surfaceContainer,
                  context.surfaceContainerHigh,
                ],
        ),
        borderRadius: BorderRadius.circular(AppShapes.large),
        border: isActiveToday
            ? Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // 불꽃 아이콘 + 스트릭 숫자
          _buildStreakIcon(context, currentStreak, isActiveToday),
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
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // 상태 메시지
                Text(
                  _getStatusMessage(context, isActiveToday, currentStreak),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),

                // 최장 기록 (0보다 클 때만)
                if (longestStreak > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.streak_longestRecord(longestStreak),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 오늘 활동 체크 표시
          if (isActiveToday)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 20,
                color: context.colors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakIcon(
    BuildContext context,
    int currentStreak,
    bool isActiveToday,
  ) {
    final iconColor = currentStreak > 0
        ? const Color(0xFFFF6B35) // 불꽃 오렌지
        : context.colors.onSurfaceVariant;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: currentStreak > 0
            ? iconColor.withValues(alpha: 0.15)
            : context.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            currentStreak > 0 ? Icons.local_fire_department : Icons.schedule,
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
              ),
            ),
          ],
        ],
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
