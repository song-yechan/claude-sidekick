import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/categories/categories_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late AnimationController _pageController;
  late AnimationController _indicatorController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _indicatorAnimation;

  static const _routes = ['/', '/search', '/library', '/categories'];

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    CategoriesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    );
    _updateSlideAnimation(true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  void _updateSlideAnimation(bool movingRight) {
    _slideAnimation = Tween<Offset>(
      begin: movingRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
  }

  int _getIndexFromLocation(String location) {
    final index = _routes.indexOf(location);
    return index >= 0 ? index : 0;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    final movingRight = index > _currentIndex;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    _updateSlideAnimation(movingRight);
    _pageController.forward(from: 0);
    _indicatorController.forward(from: 0);

    // GoRouter 상태 동기화
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // GoRouter 위치와 동기화
    final location = GoRouterState.of(context).matchedLocation;
    final routeIndex = _getIndexFromLocation(location);

    if (routeIndex != _currentIndex && !_pageController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && routeIndex != _currentIndex) {
          final movingRight = routeIndex > _currentIndex;
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = routeIndex;
          });
          _updateSlideAnimation(movingRight);
          _pageController.forward(from: 0);
          _indicatorController.forward(from: 0);
        }
      });
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          return Stack(
            children: [
              // 이전 화면 (슬라이드 아웃)
              if (_pageController.isAnimating)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: _currentIndex > _previousIndex
                        ? const Offset(-0.3, 0.0)
                        : const Offset(0.3, 0.0),
                  ).animate(CurvedAnimation(
                    parent: _pageController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: _screens[_previousIndex],
                ),
              // 현재 화면 (슬라이드 인)
              SlideTransition(
                position: _slideAnimation,
                child: _screens[_currentIndex],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
      _NavItem(icon: Icons.search_outlined, selectedIcon: Icons.search, label: '검색'),
      _NavItem(icon: Icons.library_books_outlined, selectedIcon: Icons.library_books, label: '서재'),
      _NavItem(icon: Icons.category_outlined, selectedIcon: Icons.category, label: '카테고리'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              // 애니메이션 인디케이터
              AnimatedBuilder(
                animation: _indicatorAnimation,
                builder: (context, child) {
                  final itemWidth = MediaQuery.of(context).size.width / items.length;
                  final startPos = _previousIndex * itemWidth;
                  final endPos = _currentIndex * itemWidth;
                  final currentPos = startPos + (endPos - startPos) * _indicatorAnimation.value;

                  return Positioned(
                    left: currentPos + itemWidth * 0.15,
                    top: 4,
                    child: Container(
                      width: itemWidth * 0.7,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
              // 네비게이션 아이템
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == _currentIndex;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onItemTapped(index),
                        splashColor: context.colors.primary.withValues(alpha: 0.1),
                        highlightColor: context.colors.primary.withValues(alpha: 0.05),
                        child: SizedBox(
                          height: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  key: ValueKey(isSelected),
                                  size: 24,
                                  color: isSelected
                                      ? context.colors.primary
                                      : context.colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? context.colors.primary
                                      : context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
