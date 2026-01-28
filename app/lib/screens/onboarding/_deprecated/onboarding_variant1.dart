/// [DEPRECATED] 시안 1: 혜택 중심형 (Calm, Blinkist 스타일)
///
/// 현재 사용하지 않는 온보딩 시안입니다.
/// 향후 A/B 테스트를 위해 보관합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../providers/onboarding_provider.dart';

/// 시안 1: 혜택 중심형 (Calm, Blinkist 스타일)
class OnboardingVariant1 extends ConsumerStatefulWidget {
  const OnboardingVariant1({super.key});

  @override
  ConsumerState<OnboardingVariant1> createState() => _OnboardingVariant1State();
}

class _OnboardingVariant1State extends ConsumerState<OnboardingVariant1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPage> _getPages(BuildContext context) => [
    _OnboardingPage(
      icon: Icons.camera_alt_rounded,
      title: context.l10n.onboarding_benefit_title1,
      subtitle: context.l10n.onboarding_benefit_desc1,
      color: const Color(0xFF5B6BBF),
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: context.l10n.note_aiSummarize,
      subtitle: context.l10n.onboarding_benefit_desc2,
      color: const Color(0xFF795369),
    ),
    _OnboardingPage(
      icon: Icons.calendar_month_rounded,
      title: context.l10n.onboarding_benefit_title3,
      subtitle: context.l10n.onboarding_benefit_desc3,
      color: const Color(0xFF2E7D32),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Skip 버튼
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: () => _complete(context),
                  child: Text(
                    context.l10n.common_skip,
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _getPages(context).length,
                itemBuilder: (context, index) {
                  final page = _getPages(context)[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 아이콘 컨테이너
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),

                        // 타이틀
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 서브타이틀
                        Text(
                          page.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _getPages(context).length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _getPages(context).length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _complete(context);
                    }
                  },
                  child: Text(
                    _currentPage < _getPages(context).length - 1
                        ? context.l10n.common_next
                        : context.l10n.common_start,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _complete(BuildContext context) {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.go('/');
  }
}

/// 온보딩 페이지 데이터 클래스
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
