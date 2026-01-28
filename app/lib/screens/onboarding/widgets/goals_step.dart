/// 온보딩 목표 선택 스텝
///
/// 사용자의 독서 목표를 선택받는 스텝입니다.
/// 복수 선택이 가능합니다.
library;

import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 목표 선택 스텝 위젯
class GoalsStep extends StatelessWidget {
  /// 선택된 목표 목록
  final List<String> selectedGoals;

  /// 목표 선택/해제 콜백
  final void Function(String goal) onGoalToggle;

  /// 다음 단계로 이동하는 콜백
  final VoidCallback onNext;

  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('📖', context.l10n.onboarding_buildHabit),
      ('✨', context.l10n.onboarding_collectSentences),
      ('📝', context.l10n.onboarding_keepRecord),
      ('🧠', context.l10n.onboarding_rememberContent),
    ];

    return Padding(
      key: const ValueKey('goals'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.l10n.onboarding_whatDoYouWant,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.onboarding_multiSelect,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ...goals.map((goal) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _GoalOption(
              emoji: goal.$1,
              text: goal.$2,
              isSelected: selectedGoals.contains(goal.$2),
              onTap: () => onGoalToggle(goal.$2),
            ),
          )),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedGoals.isNotEmpty ? onNext : null,
              child: Text(context.l10n.common_next),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// 목표 선택 옵션 위젯
class _GoalOption extends StatelessWidget {
  final String emoji;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.emoji,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.medium),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
