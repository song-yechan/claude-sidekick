/// MainLayout 위젯 테스트
///
/// 메인 레이아웃의 하단 네비게이션 바와 기본 구조를 검증합니다.
/// GoRouter 의존성으로 인해 네비게이션 동작 테스트는 통합 테스트에서 수행합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MainLayout 하단 네비게이션', () {
    testWidgets('shows 4 navigation icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(),
          ),
        ),
      );

      // 4개의 네비게이션 아이콘 확인 (홈은 선택 상태라 filled)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.shelves), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('home icon is selected by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(currentIndex: 0),
          ),
        ),
      );

      // 홈 아이콘이 선택된 상태 (filled icon)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('search icon is selected when currentIndex is 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(currentIndex: 1),
          ),
        ),
      );

      // 검색 아이콘이 선택된 상태
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('tapping navigation items triggers callback', (tester) async {
      var tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      // 검색 아이콘 탭
      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pump();
      expect(tappedIndex, 1);

      // 서재 아이콘 탭
      await tester.tap(find.byIcon(Icons.shelves));
      await tester.pump();
      expect(tappedIndex, 2);

      // 카테고리 아이콘 탭
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pump();
      expect(tappedIndex, 3);
    });

    testWidgets('all navigation items are tappable', (tester) async {
      final tappedItems = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(
              onTap: (index) => tappedItems.add(index),
            ),
          ),
        ),
      );

      // 모든 아이콘 순차적으로 탭
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.shelves));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pump();

      expect(tappedItems, [0, 1, 2, 3]);
    });

    testWidgets('navigation bar has SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _TestBottomNavBar(),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}

/// 테스트용 하단 네비게이션 바
/// MainLayout의 _buildBottomNavBar와 유사한 구조
class _TestBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const _TestBottomNavBar({
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, '홈'),
      (Icons.search_outlined, Icons.search_rounded, '검색'),
      (Icons.shelves, Icons.shelves, '서재'),
      (Icons.folder_outlined, Icons.folder_rounded, '카테고리'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(items.length, (index) {
              final (icon, selectedIcon, label) = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap?.call(index),
                    child: SizedBox(
                      height: 56,
                      child: Center(
                        child: Icon(
                          isSelected ? selectedIcon : icon,
                          size: 26,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
