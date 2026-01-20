import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
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

  List<OnboardingPage> _getPages(BuildContext context) => [
    OnboardingPage(
      icon: Icons.camera_alt_rounded,
      title: context.l10n.onboarding_benefit_title1,
      subtitle: context.l10n.onboarding_benefit_desc1,
      color: const Color(0xFF5B6BBF),
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: context.l10n.note_aiSummarize,
      subtitle: context.l10n.onboarding_benefit_desc2,
      color: const Color(0xFF795369),
    ),
    OnboardingPage(
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
                    _currentPage < _getPages(context).length - 1 ? context.l10n.common_next : context.l10n.common_start,
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
            Padding(
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
      case 3:
        return _buildNotificationStep(context);
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
            context.l10n.auth_welcomeWithEmoji,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.onboarding_minimal_cta,
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
      ('📖', context.l10n.onboarding_buildHabit),
      ('✨', context.l10n.onboarding_collectSentences),
      ('📝', context.l10n.onboarding_keepRecord),
      ('🧠', context.l10n.onboarding_rememberContent),
    ];

    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.l10n.onboarding_whatDoYouWant,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.onboarding_multiSelect,
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
      (context.l10n.onboarding_habit_daily, context.l10n.onboarding_habit_10min),
      (context.l10n.onboarding_freqMedium, context.l10n.onboarding_habit_title),
      (context.l10n.onboarding_freqOccasional, context.l10n.onboarding_habit_noStress),
    ];

    return Padding(
      key: const ValueKey(2),
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
            child: _buildFrequencyOption(context, freq.$1, freq.$2),
          )),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedFrequency != null
                  ? () {
                      setState(() {
                        _currentStep = 3;
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

  Widget _buildNotificationStep(BuildContext context) {
    return Padding(
      key: const ValueKey(3),
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
          GestureDetector(
            onTap: () {
              setState(() {
                _notificationEnabled = !_notificationEnabled;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _notificationEnabled
                    ? context.colors.primaryContainer
                    : context.surfaceContainer,
                borderRadius: BorderRadius.circular(AppShapes.medium),
                border: Border.all(
                  color: _notificationEnabled
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                  width: _notificationEnabled ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: _notificationEnabled
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
                    value: _notificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationEnabled = value;
                      });
                    },
                    activeColor: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 시간 선택 (알림 활성화 시만 표시)
          if (_notificationEnabled)
            GestureDetector(
              onTap: () => _showTimePicker(context),
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
                            _formatTime(_notificationTime),
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
              onPressed: () => _completeWithNotification(context),
              child: Text(context.l10n.common_done),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 건너뛰기 버튼
          SizedBox(
            width: double.infinity,
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
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
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
      setState(() {
        _notificationTime = newTime;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _completeWithNotification(BuildContext context) async {
    if (_notificationEnabled) {
      // 알림 설정 저장
      final notifier = ref.read(notificationNotifierProvider.notifier);
      await notifier.loadSettings();
      await notifier.setNotificationEnabled(true);
      await notifier.setNotificationTime(_notificationTime);
    }
    if (!mounted) return;
    _complete(context);
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
