/// 알림 설정 화면
///
/// 사용자가 독서 리마인더 알림을 설정할 수 있는 화면입니다.
/// - 알림 활성화/비활성화
/// - 알림 시간 설정
/// - 스마트 넛지 활성화/비활성화
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 알림 설정 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationNotifierProvider);
    final settings = notificationState.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notification_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                // 알림 활성화 섹션
                _buildSectionHeader(context, context.l10n.notification_title),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: context.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppShapes.large),
                  ),
                  child: Column(
                    children: [
                      // 알림 활성화 토글
                      _NotificationToggleTile(
                        icon: Icons.notifications_rounded,
                        title: context.l10n.notification_enable,
                        subtitle: context.l10n.notification_enableDesc,
                        value: settings.enabled,
                        onChanged: _onNotificationEnabledChanged,
                      ),
                      if (settings.enabled) ...[
                        Divider(
                          height: 1,
                          indent: 56,
                          color: context.colors.outlineVariant,
                        ),
                        // 알림 시간 설정
                        _NotificationTimeTile(
                          icon: Icons.access_time_rounded,
                          title: context.l10n.notification_time,
                          subtitle: context.l10n.notification_timeDesc,
                          time: settings.time,
                          onTap: () => _showTimePicker(context),
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: context.colors.outlineVariant,
                        ),
                        // 스마트 넛지 토글
                        _NotificationToggleTile(
                          icon: Icons.auto_awesome_rounded,
                          title: context.l10n.notification_smartNudge,
                          subtitle: context.l10n.notification_smartNudgeDesc,
                          value: settings.smartNudgeEnabled,
                          onChanged: _onSmartNudgeChanged,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 권한 안내 (권한이 없을 때)
                if (!settings.hasPermission && settings.enabled)
                  _buildPermissionWarning(context),

                // 에러 메시지
                if (notificationState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      notificationState.errorMessage!,
                      style: TextStyle(
                        color: context.colors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPermissionWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: context.colors.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.notification_permissionDenied,
                  style: TextStyle(
                    color: context.colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _openAppSettings,
                  child: Text(
                    context.l10n.notification_goToSettings,
                    style: TextStyle(
                      color: context.colors.onErrorContainer,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onNotificationEnabledChanged(bool enabled) async {
    final success = await ref
        .read(notificationNotifierProvider.notifier)
        .setNotificationEnabled(enabled);

    if (!success && mounted) {
      // 권한 거부됨 - 이미 상태에 반영됨
    }
  }

  Future<void> _onSmartNudgeChanged(bool enabled) async {
    await ref
        .read(notificationNotifierProvider.notifier)
        .setSmartNudgeEnabled(enabled);
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final settings = ref.read(notificationNotifierProvider).settings;
    final currentTime = settings.time;

    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.colors,
          ),
          child: child!,
        );
      },
    );

    if (newTime != null && newTime != currentTime) {
      await ref
          .read(notificationNotifierProvider.notifier)
          .setNotificationTime(newTime);
    }
  }

  void _openAppSettings() {
    // 앱 설정 화면으로 이동 (플랫폼별 구현 필요)
    // iOS: app-settings:
    // Android: ACTION_APPLICATION_DETAILS_SETTINGS
  }
}

/// 알림 토글 타일
class _NotificationToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value
              ? context.colors.primaryContainer
              : context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: Icon(
          icon,
          color: value
              ? context.colors.onPrimaryContainer
              : context.colors.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.colors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: context.colors.primary,
      ),
    );
  }
}

/// 알림 시간 설정 타일
class _NotificationTimeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _NotificationTimeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(time);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: Icon(
          icon,
          color: context.colors.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: context.colors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppShapes.small),
        ),
        child: Text(
          formattedTime,
          style: TextStyle(
            color: context.colors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
