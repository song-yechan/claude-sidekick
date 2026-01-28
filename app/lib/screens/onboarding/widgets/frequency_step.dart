/// 온보딩 독서 빈도 선택 스텝
///
/// 사용자의 독서 빈도를 선택받는 스텝입니다.
/// 단일 선택만 가능합니다.
library;

import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 독서 빈도 선택 스텝 위젯
class FrequencyStep extends StatelessWidget {
  /// 선택된 빈도
  final String? selectedFrequency;

  /// 빈도 선택 콜백
  final void Function(String frequency) onFrequencySelect;

  /// 다음 단계로 이동하는 콜백
  final VoidCallback onNext;

  const FrequencyStep({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencySelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final frequencies = [
      (context.l10n.onboarding_habit_daily, context.l10n.onboarding_habit_10min),
      (context.l10n.onboarding_freqMedium, context.l10n.onboarding_habit_title),
      (context.l10n.onboarding_freqOccasional, context.l10n.onboarding_habit_noStress),
    ];

    return Padding(
      key: const ValueKey('frequency'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.l10n.onboarding_howOften,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.onboarding_customExperience,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ...frequencies.map((freq) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _FrequencyOption(
              title: freq.$1,
              subtitle: freq.$2,
              isSelected: selectedFrequency == freq.$1,
              onTap: () => onFrequencySelect(freq.$1),
            ),
          )),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedFrequency != null ? onNext : null,
              child: Text(context.l10n.common_next),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// 빈도 선택 옵션 위젯
class _FrequencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.title,
    required this.subtitle,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
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
