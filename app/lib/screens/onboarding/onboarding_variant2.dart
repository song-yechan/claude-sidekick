/// 온보딩 시안 2: 인터랙티브형 (Spotify, Duolingo 스타일)
///
/// 현재 사용 중인 메인 온보딩 플로우입니다.
/// 4개 스텝으로 구성:
/// 1. 환영 (Welcome)
/// 2. 목표 선택 (Goals)
/// 3. 빈도 선택 (Frequency)
/// 4. 알림 설정 (Notification)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/welcome_step.dart';
import 'widgets/goals_step.dart';
import 'widgets/frequency_step.dart';
import 'widgets/notification_step.dart';

/// 온보딩 시안 2: 인터랙티브형
class OnboardingVariant2 extends ConsumerStatefulWidget {
  const OnboardingVariant2({super.key});

  @override
  ConsumerState<OnboardingVariant2> createState() => _OnboardingVariant2State();
}

class _OnboardingVariant2State extends ConsumerState<OnboardingVariant2> {
  int _currentStep = 0;
  final List<String> _selectedGoals = [];
  String? _selectedFrequency;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 21, minute: 0);
  bool _notificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // 프로그레스 바 + 언어 선택
            _buildHeader(context),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: context.colors.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildLanguageDropdown(context),
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: _complete,
            child: Text(
              context.l10n.common_skip,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return WelcomeStep(
          onNext: () => setState(() => _currentStep = 1),
        );
      case 1:
        return GoalsStep(
          selectedGoals: _selectedGoals,
          onGoalToggle: (goal) {
            setState(() {
              if (_selectedGoals.contains(goal)) {
                _selectedGoals.remove(goal);
              } else {
                _selectedGoals.add(goal);
              }
            });
          },
          onNext: () => setState(() => _currentStep = 2),
        );
      case 2:
        return FrequencyStep(
          selectedFrequency: _selectedFrequency,
          onFrequencySelect: (frequency) {
            setState(() => _selectedFrequency = frequency);
          },
          onNext: () => setState(() => _currentStep = 3),
        );
      case 3:
        return NotificationStep(
          notificationEnabled: _notificationEnabled,
          notificationTime: _notificationTime,
          onToggle: (enabled) {
            setState(() => _notificationEnabled = enabled);
          },
          onTimeChange: (time) {
            setState(() => _notificationTime = time);
          },
          onComplete: _completeWithNotification,
          onSkip: _complete,
        );
      default:
        return const SizedBox();
    }
  }

  /// 언어 선택 드롭다운 버튼
  Widget _buildLanguageDropdown(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    return PopupMenuButton<AppLanguage>(
      initialValue: currentLanguage,
      onSelected: (AppLanguage language) {
        ref.read(languageProvider.notifier).setLanguage(language);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppLanguage.ko,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇰🇷'),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.settings_language_korean),
            ],
          ),
        ),
        PopupMenuItem(
          value: AppLanguage.en,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: AppSpacing.sm),
              Text(context.l10n.settings_language_english),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppShapes.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage == AppLanguage.ko ? '🇰🇷' : '🇺🇸',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeWithNotification() async {
    if (_notificationEnabled) {
      // 알림 설정 저장
      final notifier = ref.read(notificationNotifierProvider.notifier);
      await notifier.loadSettings();
      await notifier.setNotificationEnabled(true);
      await notifier.setNotificationTime(_notificationTime);
    }
    if (!mounted) return;
    _complete();
  }

  void _complete() {
    // 사용자 선택값 저장과 함께 온보딩 완료
    ref.read(onboardingProvider.notifier).completeOnboarding(
      goals: _selectedGoals,
      frequency: _selectedFrequency,
    );
    context.go('/');
  }
}
