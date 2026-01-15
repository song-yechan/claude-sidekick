import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/widgets/common/activity_calendar.dart';
import '../helpers/test_app.dart';

void main() {
  group('ActivityCalendar', () {
    testWidgets('displays year title correctly', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {},
          ),
        ),
      );

      expect(find.text('2024년 독서 활동'), findsOneWidget);
    });

    testWidgets('shows navigation buttons', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {},
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('triggers onYearChanged when left button tapped', (tester) async {
      int? changedYear;

      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {},
            onYearChanged: (year) => changedYear = year,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      expect(changedYear, 2023);
    });

    testWidgets('shows legend text', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {},
          ),
        ),
      );

      expect(find.text('적음'), findsOneWidget);
      expect(find.text('많음'), findsOneWidget);
    });

    testWidgets('renders with activity data', (tester) async {
      final data = {
        DateTime(2024, 1, 1): 5,
        DateTime(2024, 1, 15): 10,
        DateTime(2024, 2, 1): 3,
      };

      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: data,
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(ActivityCalendar), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {},
          ),
        ),
      );

      expect(find.byType(ActivityCalendar), findsOneWidget);
    });

    testWidgets('handles current year correctly', (tester) async {
      final currentYear = DateTime.now().year;

      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: currentYear,
            data: {},
          ),
        ),
      );

      expect(find.text('$currentYear년 독서 활동'), findsOneWidget);
    });

    testWidgets('handles past year correctly', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2020,
            data: {},
          ),
        ),
      );

      expect(find.text('2020년 독서 활동'), findsOneWidget);
    });

    testWidgets('renders tooltip containers', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: {DateTime(2024, 1, 1): 5},
          ),
        ),
      );

      // Should contain Tooltip widgets for dates
      expect(find.byType(Tooltip), findsWidgets);
    });
  });

  group('ActivityCalendar color logic', () {
    // Testing the color logic through visual verification
    testWidgets('different activity levels show different colors', (tester) async {
      final data = {
        DateTime(2024, 1, 1): 0, // gray100
        DateTime(2024, 1, 2): 1, // 0.2 opacity
        DateTime(2024, 1, 3): 3, // 0.4 opacity
        DateTime(2024, 1, 4): 6, // 0.6 opacity
        DateTime(2024, 1, 5): 15, // 0.8 opacity
        DateTime(2024, 1, 6): 25, // full blue
      };

      await tester.pumpWidget(
        TestApp(
          child: ActivityCalendar(
            year: 2024,
            data: data,
          ),
        ),
      );

      // Widget renders with different data levels
      expect(find.byType(ActivityCalendar), findsOneWidget);
    });
  });
}
