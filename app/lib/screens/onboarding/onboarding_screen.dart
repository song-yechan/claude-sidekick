import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/onboarding_provider.dart';

/// 온보딩 시안 선택 및 표시 화면
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _selectedVariant = 0;
  bool _showingPreview = false;

  @override
  Widget build(BuildContext context) {
    // 미리보기 모드일 때 해당 시안 화면 직접 표시 (Navigation 없이)
    if (_showingPreview) {
      debugPrint('Rendering preview mode for variant: $_selectedVariant');
      return _buildPreviewMode(context);
    }

    debugPrint('Rendering selection mode');
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(context.l10n.onboarding_styleSelection),
        backgroundColor: context.surfaceContainerLowest,
        actions: [
          TextButton(
            onPressed: () {
              // provider 상태 변경하지 않음 - 로컬 상태만 사용
              _showOnboarding(context);
            },
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

            // 하단 버튼 영역 (고정)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('Button pressed! Variant: $_selectedVariant');
                    // provider 상태 변경하지 않음 - 로컬 상태만 사용
                    _showOnboarding(context);
                  },
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
  }) {
    final isSelected = _selectedVariant == variant;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVariant = variant;
        });
      },
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
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

  void _showOnboarding(BuildContext context) {
    debugPrint('Setting preview mode ON for variant: $_selectedVariant');
    setState(() {
      _showingPreview = true;
    });
  }

  Widget _buildPreviewMode(BuildContext context) {
    return Stack(
      children: [
        // 선택된 시안 화면 표시
        _getOnboardingVariant(_selectedVariant),
        // 뒤로가기 버튼 (왼쪽 상단)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: GestureDetector(
            onTap: () {
              debugPrint('Back button pressed, returning to selection');
              setState(() {
                _showingPreview = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
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
        return const OnboardingVariant1();
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
        return const OnboardingVariant1();
    }
  }
}

/// 시안 1: 혜택 중심형 (Calm, Blinkist 스타일)
class OnboardingVariant1 extends ConsumerStatefulWidget {
  const OnboardingVariant1({super.key});

  @override
  ConsumerState<OnboardingVariant1> createState() => _OnboardingVariant1State();
}

class _OnboardingVariant1State extends ConsumerState<OnboardingVariant1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.camera_alt_rounded,
      title: '문장을 촬영하세요',
      subtitle: '책 속 마음에 드는 문장을\n카메라로 간편하게 촬영하세요',
      color: const Color(0xFF5B6BBF),
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'AI가 요약해드려요',
      subtitle: '촬영한 문장을 자동으로 인식하고\nAI가 핵심만 요약해드립니다',
      color: const Color(0xFF795369),
    ),
    OnboardingPage(
      icon: Icons.calendar_month_rounded,
      title: '독서 습관을 만드세요',
      subtitle: '매일의 독서 기록이 쌓여\n나만의 독서 캘린더가 완성됩니다',
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
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
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
                _pages.length,
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
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _complete(context);
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? context.l10n.common_next : context.l10n.common_start,
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

/// 시안 2: 인터랙티브형 (Spotify, Duolingo 스타일)
class OnboardingVariant2 extends ConsumerStatefulWidget {
  const OnboardingVariant2({super.key});

  @override
  ConsumerState<OnboardingVariant2> createState() => _OnboardingVariant2State();
}

class _OnboardingVariant2State extends ConsumerState<OnboardingVariant2> {
  int _currentStep = 0;
  final List<String> _selectedGoals = [];
  String? _selectedFrequency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // 프로그레스 바 + 언어 선택
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 3,
                        backgroundColor: context.colors.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // 언어 선택 드롭다운
                  _buildLanguageDropdown(context),
                  const SizedBox(width: AppSpacing.xs),
                  TextButton(
                    onPressed: () => _complete(context),
                    child: Text(
                      context.l10n.common_skip,
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(context);
      case 1:
        return _buildGoalsStep(context);
      case 2:
        return _buildFrequencyStep(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcomeStep(BuildContext context) {
    return Padding(
      key: const ValueKey(0),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 60,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '환영합니다! 👋',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '북스크라이브와 함께\n더 풍요로운 독서 생활을 시작해보세요',
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              child: Text(context.l10n.common_start),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep(BuildContext context) {
    final goals = [
      ('📖', '독서 습관 만들기'),
      ('✨', '좋은 문장 수집하기'),
      ('📝', '독서 기록 남기기'),
      ('🧠', '읽은 내용 기억하기'),
    ];

    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '북스크라이브를 통해\n무엇을 하고 싶으세요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '여러 개를 선택할 수 있어요',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ...goals.map((goal) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildGoalOption(context, goal.$1, goal.$2),
          )),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedGoals.isNotEmpty
                  ? () {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  : null,
              child: Text(context.l10n.common_next),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildGoalOption(BuildContext context, String emoji, String text) {
    final isSelected = _selectedGoals.contains(text);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(text);
          } else {
            _selectedGoals.add(text);
          }
        });
      },
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

  Widget _buildFrequencyStep(BuildContext context) {
    final frequencies = [
      ('매일 조금씩', '하루 10분이면 충분해요'),
      ('주 2-3회', '꾸준함이 중요해요'),
      ('여유 있을 때', '부담 없이 즐기세요'),
    ];

    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '얼마나 자주\n책을 읽으시나요?',
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
            child: _buildFrequencyOption(context, freq.$1, freq.$2),
          )),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedFrequency != null
                  ? () => _complete(context)
                  : null,
              child: Text(context.l10n.common_done),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(BuildContext context, String title, String subtitle) {
    final isSelected = _selectedFrequency == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = title;
        });
      },
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

  void _complete(BuildContext context) {
    // 사용자 선택값 저장과 함께 온보딩 완료
    ref.read(onboardingProvider.notifier).completeOnboarding(
      goals: _selectedGoals,
      frequency: _selectedFrequency,
    );
    context.go('/');
  }
}

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
                '책 속 문장을 기록하는 가장 스마트한 방법',
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
                title: '촬영',
                description: '문장을 찍으면 텍스트로 변환',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeatureItem(
                context,
                icon: Icons.psychology_outlined,
                title: 'AI 요약',
                description: '핵심만 쏙쏙 정리',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildFeatureItem(
                context,
                icon: Icons.grid_view_rounded,
                title: '캘린더',
                description: '나만의 독서 기록',
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
                  child: const Text('바로 시작하기'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 부가 정보
              Text(
                '30초면 시작할 수 있어요',
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

/// 온보딩 페이지 데이터 클래스
class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
