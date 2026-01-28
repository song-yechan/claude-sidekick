/// 온보딩 화면
///
/// 시안 선택 화면과 각 시안을 표시합니다.
/// 현재 OnboardingVariant2가 메인으로 사용됩니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'onboarding_variant2.dart';
import '_deprecated/onboarding_variant1.dart';
import '_deprecated/onboarding_variant3.dart';

// 메인 온보딩 화면으로 Variant2를 re-export
export 'onboarding_variant2.dart';

/// 온보딩 시안 선택 및 표시 화면
///
/// 개발/테스트 용도로 여러 시안을 선택할 수 있습니다.
/// 프로덕션에서는 OnboardingVariant2를 직접 사용합니다.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _selectedVariant = 1; // 기본값: Variant2 (인덱스 1)
  bool _showingPreview = false;

  @override
  Widget build(BuildContext context) {
    // 미리보기 모드일 때 해당 시안 화면 직접 표시
    if (_showingPreview) {
      return _buildPreviewMode(context);
    }

    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(context.l10n.onboarding_styleSelection),
        backgroundColor: context.surfaceContainerLowest,
        actions: [
          TextButton(
            onPressed: () => _showOnboarding(),
            child: Text(context.l10n.common_preview),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.onboarding_selectStyle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.onboarding_selectFromThree,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    _buildVariantCard(
                      context,
                      variant: 0,
                      title: context.l10n.onboarding_style1Title,
                      description: context.l10n.onboarding_style1Desc,
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildVariantCard(
                      context,
                      variant: 1,
                      title: context.l10n.onboarding_style2Title,
                      description: context.l10n.onboarding_style2Desc,
                      icon: Icons.touch_app,
                      recommended: true,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildVariantCard(
                      context,
                      variant: 2,
                      title: context.l10n.onboarding_style3Title,
                      description: context.l10n.onboarding_style3Desc,
                      icon: Icons.bolt,
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showOnboarding(),
                  child: Text(context.l10n.onboarding_previewSelected),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantCard(
    BuildContext context, {
    required int variant,
    required String title,
    required String description,
    required IconData icon,
    bool recommended = false,
  }) {
    final isSelected = _selectedVariant == variant;

    return GestureDetector(
      onTap: () => setState(() => _selectedVariant = variant),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.surfaceContainer,
          borderRadius: BorderRadius.circular(AppShapes.large),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppShapes.medium),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
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

  void _showOnboarding() {
    setState(() => _showingPreview = true);
  }

  Widget _buildPreviewMode(BuildContext context) {
    return Stack(
      children: [
        // 선택된 시안 화면 표시
        _getOnboardingVariant(_selectedVariant),
        // 뒤로가기 버튼
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: GestureDetector(
            onTap: () => setState(() => _showingPreview = false),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getOnboardingVariant(int variant) {
    switch (variant) {
      case 0:
        return const OnboardingVariant1();
      case 1:
        return const OnboardingVariant2();
      case 2:
        return const OnboardingVariant3();
      default:
        return const OnboardingVariant2();
    }
  }
}

/// 온보딩 미리보기 화면 (라우터에서 사용)
class OnboardingPreviewScreen extends ConsumerWidget {
  final int variant;

  const OnboardingPreviewScreen({super.key, required this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (variant) {
      case 0:
        return const OnboardingVariant1();
      case 1:
        return const OnboardingVariant2();
      case 2:
        return const OnboardingVariant3();
      default:
        return const OnboardingVariant2();
    }
  }
}
