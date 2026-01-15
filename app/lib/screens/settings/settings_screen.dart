import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          // 테마 설정 섹션
          _buildSectionHeader(context, context.l10n.settings_display),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppShapes.large),
            ),
            child: Column(
              children: [
                _ThemeOptionTile(
                  icon: Icons.brightness_auto_rounded,
                  title: context.l10n.settings_theme_system,
                  subtitle: context.l10n.settings_theme_systemDesc,
                  isSelected: currentTheme == AppThemeMode.system,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.system),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                _ThemeOptionTile(
                  icon: Icons.light_mode_rounded,
                  title: context.l10n.settings_theme_light,
                  subtitle: context.l10n.settings_theme_lightDesc,
                  isSelected: currentTheme == AppThemeMode.light,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.light),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                _ThemeOptionTile(
                  icon: Icons.dark_mode_rounded,
                  title: context.l10n.settings_theme_dark,
                  subtitle: context.l10n.settings_theme_darkDesc,
                  isSelected: currentTheme == AppThemeMode.dark,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 언어 설정 섹션
          _buildSectionHeader(context, context.l10n.settings_language),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppShapes.large),
            ),
            child: Column(
              children: [
                _LanguageOptionTile(
                  flag: '🇰🇷',
                  title: context.l10n.settings_language_korean,
                  subtitle: context.l10n.settings_language_koreanDesc,
                  isSelected: currentLanguage == AppLanguage.ko,
                  onTap: () => ref
                      .read(languageProvider.notifier)
                      .setLanguage(AppLanguage.ko),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                _LanguageOptionTile(
                  flag: '🇺🇸',
                  title: context.l10n.settings_language_english,
                  subtitle: context.l10n.settings_language_englishDesc,
                  isSelected: currentLanguage == AppLanguage.en,
                  onTap: () => ref
                      .read(languageProvider.notifier)
                      .setLanguage(AppLanguage.en),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 계정 섹션
          _buildSectionHeader(context, context.l10n.account_title),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppShapes.large),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppShapes.medium),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: context.colors.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    authState.user?.email ?? context.l10n.auth_loginRequired,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    context.l10n.account_loggedIn,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.errorContainer,
                      borderRadius: BorderRadius.circular(AppShapes.medium),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: context.colors.onErrorContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    context.l10n.auth_logout,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colors.error,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.error,
                      borderRadius: BorderRadius.circular(AppShapes.medium),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: context.colors.onError,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    context.l10n.account_delete,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colors.error,
                    ),
                  ),
                  subtitle: Text(
                    context.l10n.account_deleteWarning,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 앱 정보
          _buildSectionHeader(context, context.l10n.settings_appInfo),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppShapes.large),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppShapes.medium),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: context.colors.onSecondaryContainer,
                  size: 20,
                ),
              ),
              title: Text(
                context.l10n.common_version,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
              trailing: Text(
                '1.0.0',
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                ),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.l10n.auth_logout,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        content: Text(
          context.l10n.auth_logoutConfirm,
          style: TextStyle(
            fontSize: 15,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop(); // 설정 화면 닫기
              ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.auth_logout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: context.colors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.account_delete,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.account_deleteConfirm,
              style: TextStyle(
                fontSize: 15,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeleteItem(context, context.l10n.library_allBooks),
            _buildDeleteItem(context, context.l10n.library_allNotes),
            _buildDeleteItem(context, context.l10n.account_info),
            const SizedBox(height: 16),
            Text(
              context.l10n.account_deleteIrreversible,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // 로딩 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(
                        color: context.colors.primary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        context.l10n.account_deleting,
                        style: TextStyle(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final success = await ref.read(authProvider.notifier).deleteAccount();

              if (context.mounted) {
                Navigator.pop(context); // 로딩 다이얼로그 닫기

                if (success) {
                  context.go('/'); // 홈으로 이동 (로그인 화면으로 리다이렉트됨)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.account_deleteFailed),
                      backgroundColor: context.colors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.common_delete),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.remove_circle_outline,
            size: 16,
            color: context.colors.error,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? context.colors.onPrimaryContainer
              : context.colors.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: context.colors.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: Center(
          child: Text(
            flag,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: context.colors.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
