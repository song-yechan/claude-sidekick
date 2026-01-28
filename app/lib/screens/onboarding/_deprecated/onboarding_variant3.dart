/// [DEPRECATED] 시안 3: 미니멀 빠른시작 (Loom 스타일)
///
/// 현재 사용하지 않는 온보딩 시안입니다.
/// 향후 A/B 테스트를 위해 보관합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../providers/onboarding_provider.dart';

/// 시안 3: 미니멀 빠른시작 (Loom 스타일)
class OnboardingVariant3 extends ConsumerWidget {
  const OnboardingVariant3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고/아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppShapes.extraLarge),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 50,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 환영 메시지
              Text(
                context.l10n.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.onboarding_minimal_subhead,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // 핵심 기능 3가지
              _buildFeatureItem(
                context,
                icon: Icons.camera_alt_outlined,
                title: context.l10n.ocr_capture,
                description: context.l10n.onboarding_benefit_title2,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeatureItem(
                context,
                icon: Icons.psychology_outlined,
                title: context.l10n.note_aiSummary,
                description: context.l10n.ocr_summarize,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeatureItem(
                context,
                icon: Icons.grid_view_rounded,
                title: context.l10n.calendar_title,
                description: context.l10n.onboarding_benefit_title4,
              ),

              const Spacer(),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(onboardingProvider.notifier).completeOnboarding();
                    context.go('/');
                  },
                  child: Text(context.l10n.common_startNow),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 부가 정보
              Text(
                context.l10n.auth_quickStart,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppShapes.medium),
          ),
          child: Icon(
            icon,
            color: context.colors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
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
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
