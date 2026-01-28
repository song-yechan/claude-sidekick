/// 온보딩 알림 설정 스텝
///
/// 독서 알림 활성화 여부와 시간을 설정받는 마지막 스텝입니다.
library;

import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 알림 설정 스텝 위젯
class NotificationStep extends StatelessWidget {
  /// 알림 활성화 여부
  final bool notificationEnabled;

  /// 알림 시간
  final TimeOfDay notificationTime;

  /// 알림 활성화 토글 콜백
  final void Function(bool enabled) onToggle;

  /// 시간 변경 콜백
  final void Function(TimeOfDay time) onTimeChange;

  /// 완료 버튼 콜백
  final VoidCallback onComplete;

  /// 건너뛰기 버튼 콜백
  final VoidCallback onSkip;

  const NotificationStep({
    super.key,
    required this.notificationEnabled,
    required this.notificationTime,
    required this.onToggle,
    required this.onTimeChange,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('notification'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // 아이콘
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 50,
                color: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 제목
          Center(
            child: Text(
              context.l10n.onboarding_notification_title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              context.l10n.onboarding_notification_subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // 알림 활성화 토글
          _NotificationToggle(
            enabled: notificationEnabled,
            onToggle: onToggle,
          ),
          const SizedBox(height: AppSpacing.md),

          // 시간 선택 (알림 활성화 시만 표시)
          if (notificationEnabled)
            _TimeSelector(
              time: notificationTime,
              onTap: () => _showTimePicker(context),
            ),

          const Spacer(),

          // 힌트 텍스트
          Center(
            child: Text(
              context.l10n.onboarding_notification_skipHint,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 완료 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onComplete,
              child: Text(context.l10n.common_done),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 건너뛰기 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                context.l10n.common_skip,
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.colors,
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      onTimeChange(newTime);
    }
  }
}

/// 알림 활성화 토글 위젯
class _NotificationToggle extends StatelessWidget {
  final bool enabled;
  final void Function(bool) onToggle;

  const _NotificationToggle({
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!enabled),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: enabled
              ? context.colors.primaryContainer
              : context.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.medium),
          border: Border.all(
            color: enabled
                ? context.colors.primary
                : context.colors.outlineVariant,
            width: enabled ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: enabled
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.l10n.notification_enable,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Switch.adaptive(
              value: enabled,
              onChanged: onToggle,
              activeTrackColor: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 시간 선택 위젯
class _TimeSelector extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppShapes.medium),
          border: Border.all(
            color: context.colors.primary,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: context.colors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.onboarding_notification_timeLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_rounded,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
