import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          // 테마 설정 섹션
          _buildSectionHeader(context, '화면'),
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
                  title: '시스템 설정',
                  subtitle: '기기 설정에 따라 자동 전환',
                  isSelected: currentTheme == AppThemeMode.system,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.system),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                _ThemeOptionTile(
                  icon: Icons.light_mode_rounded,
                  title: '라이트 모드',
                  subtitle: '밝은 테마 사용',
                  isSelected: currentTheme == AppThemeMode.light,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.light),
                ),
                Divider(height: 1, indent: 56, color: context.colors.outlineVariant),
                _ThemeOptionTile(
                  icon: Icons.dark_mode_rounded,
                  title: '다크 모드',
                  subtitle: '어두운 테마 사용',
                  isSelected: currentTheme == AppThemeMode.dark,
                  onTap: () => ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 계정 섹션
          _buildSectionHeader(context, '계정'),
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
                    authState.user?.email ?? '로그인 필요',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '로그인된 계정',
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
                    '로그아웃',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colors.error,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 앱 정보
          _buildSectionHeader(context, '앱 정보'),
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
                '버전',
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
          '로그아웃',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            fontSize: 15,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
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
            child: const Text('로그아웃'),
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
