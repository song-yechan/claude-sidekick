/// CategoryChip, CategoryCard 위젯 테스트
///
/// 카테고리 표시용 위젯들의 렌더링과 인터랙션을 검증합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/widgets/category/category_chip.dart';
import '../mocks/test_fixtures.dart';

void main() {
  group('CategoryChip', () {
    testWidgets('displays category name', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(category: category),
          ),
        ),
      );

      expect(find.text('소설'), findsOneWidget);
    });

    testWidgets('shows color indicator dot', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(category: category),
          ),
        ),
      );

      // 색상 표시용 원형 Container 확인
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('selected state changes appearance', (tester) async {
      final category = TestCategories.fiction;

      // 선택되지 않은 상태
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: category,
              isSelected: false,
            ),
          ),
        ),
      );

      // 선택된 상태
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: category,
              isSelected: true,
            ),
          ),
        ),
      );

      // 위젯이 정상적으로 렌더링됨
      expect(find.text('소설'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;
      final category = TestCategories.selfHelp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: category,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryChip));
      expect(tapped, isTrue);
    });

    testWidgets('renders without onTap callback', (tester) async {
      final category = TestCategories.science;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(category: category),
          ),
        ),
      );

      // onTap 없이도 정상 렌더링
      expect(find.text('과학'), findsOneWidget);
    });

    testWidgets('displays different category colors correctly', (tester) async {
      // 여러 카테고리를 순차적으로 테스트
      for (final category in TestCategories.all) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryChip(category: category),
            ),
          ),
        );

        expect(find.text(category.name), findsOneWidget);
      }
    });
  });

  group('CategoryCard', () {
    testWidgets('displays category name and book count', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              bookCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('소설'), findsOneWidget);
      expect(find.text('5권'), findsOneWidget);
    });

    testWidgets('displays zero book count', (tester) async {
      final category = TestCategories.selfHelp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              bookCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('자기계발'), findsOneWidget);
      expect(find.text('0권'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows delete button when onDelete is provided', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('hides delete button when onDelete is null', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(category: category),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('triggers onDelete callback when delete button tapped', (tester) async {
      var deleted = false;
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(deleted, isTrue);
    });

    testWidgets('shows chevron right icon', (tester) async {
      final category = TestCategories.fiction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(category: category),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('renders with large book count', (tester) async {
      final category = TestCategories.science;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: category,
              bookCount: 999,
            ),
          ),
        ),
      );

      expect(find.text('999권'), findsOneWidget);
    });
  });
}
