import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/core/theme.dart';

void main() {
  group('TossColors', () {
    test('primary colors are defined correctly', () {
      expect(TossColors.blue, const Color(0xFF3182F6));
      expect(TossColors.blueLight, const Color(0xFFE8F3FF));
    });

    test('semantic colors are defined correctly', () {
      expect(TossColors.red, const Color(0xFFF04452));
      expect(TossColors.redLight, const Color(0xFFFFEBED));
      expect(TossColors.green, const Color(0xFF30B566));
      expect(TossColors.greenLight, const Color(0xFFE8F8EF));
      expect(TossColors.orange, const Color(0xFFFF8A00));
      expect(TossColors.orangeLight, const Color(0xFFFFF4E5));
    });

    test('gray scale colors are defined correctly', () {
      expect(TossColors.gray950, const Color(0xFF191F28));
      expect(TossColors.gray900, const Color(0xFF212529));
      expect(TossColors.gray800, const Color(0xFF333D4B));
      expect(TossColors.gray700, const Color(0xFF4E5968));
      expect(TossColors.gray600, const Color(0xFF6B7684));
      expect(TossColors.gray500, const Color(0xFF8B95A1));
      expect(TossColors.gray400, const Color(0xFFB0B8C1));
      expect(TossColors.gray300, const Color(0xFFD1D6DB));
      expect(TossColors.gray200, const Color(0xFFE5E8EB));
      expect(TossColors.gray100, const Color(0xFFF2F4F6));
      expect(TossColors.gray50, const Color(0xFFF9FAFB));
      expect(TossColors.white, const Color(0xFFFFFFFF));
    });

    test('background colors are defined correctly', () {
      expect(TossColors.bgLight, const Color(0xFFF9FAFB));
      expect(TossColors.bgDark, const Color(0xFF17171C));
    });

    test('gray scale maintains proper ordering (lighter values have higher numbers)', () {
      // Verify that gray scale follows expected brightness pattern
      expect(TossColors.gray950.computeLuminance(),
             lessThan(TossColors.gray900.computeLuminance()));
      expect(TossColors.gray900.computeLuminance(),
             lessThan(TossColors.gray800.computeLuminance()));
      expect(TossColors.gray100.computeLuminance(),
             lessThan(TossColors.gray50.computeLuminance()));
    });
  });

  group('AppTheme.light', () {
    late ThemeData lightTheme;

    setUp(() {
      lightTheme = AppTheme.light;
    });

    test('uses Material 3', () {
      expect(lightTheme.useMaterial3, isTrue);
    });

    test('has light brightness', () {
      expect(lightTheme.brightness, Brightness.light);
    });

    test('uses correct scaffold background color', () {
      expect(lightTheme.scaffoldBackgroundColor, TossColors.bgLight);
    });

    test('has correct color scheme', () {
      expect(lightTheme.colorScheme.primary, TossColors.blue);
      expect(lightTheme.colorScheme.onPrimary, TossColors.white);
      expect(lightTheme.colorScheme.error, TossColors.red);
    });

    test('appbar theme is configured correctly', () {
      expect(lightTheme.appBarTheme.elevation, 0);
      expect(lightTheme.appBarTheme.backgroundColor, TossColors.bgLight);
      expect(lightTheme.appBarTheme.centerTitle, isFalse);
    });

    test('card theme has no elevation', () {
      expect(lightTheme.cardTheme.elevation, 0);
      expect(lightTheme.cardTheme.color, TossColors.white);
    });

    test('elevated button theme is configured correctly', () {
      final buttonStyle = lightTheme.elevatedButtonTheme.style!;
      expect(
        buttonStyle.backgroundColor?.resolve({}),
        TossColors.blue,
      );
    });

    test('bottom navigation bar theme is configured correctly', () {
      expect(
        lightTheme.bottomNavigationBarTheme.backgroundColor,
        TossColors.white,
      );
      expect(
        lightTheme.bottomNavigationBarTheme.selectedItemColor,
        TossColors.gray900,
      );
    });

    test('text theme has correct heading styles', () {
      expect(lightTheme.textTheme.headlineLarge?.fontSize, 28);
      expect(lightTheme.textTheme.headlineMedium?.fontSize, 24);
      expect(lightTheme.textTheme.headlineSmall?.fontSize, 20);
    });

    test('text theme has correct body styles', () {
      expect(lightTheme.textTheme.bodyLarge?.fontSize, 16);
      expect(lightTheme.textTheme.bodyMedium?.fontSize, 14);
      expect(lightTheme.textTheme.bodySmall?.fontSize, 13);
    });
  });

  group('AppTheme.dark', () {
    late ThemeData darkTheme;

    setUp(() {
      darkTheme = AppTheme.dark;
    });

    test('uses Material 3', () {
      expect(darkTheme.useMaterial3, isTrue);
    });

    test('has dark brightness', () {
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('uses correct scaffold background color', () {
      expect(darkTheme.scaffoldBackgroundColor, TossColors.bgDark);
    });

    test('has correct color scheme', () {
      expect(darkTheme.colorScheme.primary, TossColors.blue);
      expect(darkTheme.colorScheme.onPrimary, TossColors.white);
      expect(darkTheme.colorScheme.error, TossColors.red);
    });

    test('appbar theme uses dark background', () {
      expect(darkTheme.appBarTheme.backgroundColor, TossColors.bgDark);
      expect(darkTheme.appBarTheme.foregroundColor, TossColors.gray100);
    });
  });

  group('Theme Widget Integration', () {
    testWidgets('light theme applies correctly to widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      // Scaffold should use theme's background
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('dark theme applies correctly to widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('elevated button uses theme style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });
  });
}
