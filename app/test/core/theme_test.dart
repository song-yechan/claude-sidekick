import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/core/theme.dart';

void main() {
  group('AppColors', () {
    test('primary colors are defined correctly', () {
      expect(AppColors.primary, const Color(0xFF5B6BBF));
      expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      expect(AppColors.primaryContainer, const Color(0xFFDEE0FF));
      expect(AppColors.onPrimaryContainer, const Color(0xFF151B4D));
    });

    test('secondary colors are defined correctly', () {
      expect(AppColors.secondary, const Color(0xFF5D5C71));
      expect(AppColors.onSecondary, const Color(0xFFFFFFFF));
      expect(AppColors.secondaryContainer, const Color(0xFFE2E0F9));
    });

    test('error colors are defined correctly', () {
      expect(AppColors.error, const Color(0xFFBA1A1A));
      expect(AppColors.onError, const Color(0xFFFFFFFF));
      expect(AppColors.errorContainer, const Color(0xFFFFDAD6));
    });

    test('surface colors are defined correctly', () {
      expect(AppColors.surface, const Color(0xFFFCF8FF));
      expect(AppColors.onSurface, const Color(0xFF1C1B1F));
      expect(AppColors.surfaceContainerLowest, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceContainerHigh, const Color(0xFFEBE6EE));
    });

    test('semantic colors are defined correctly', () {
      expect(AppColors.success, const Color(0xFF2E7D32));
      expect(AppColors.warning, const Color(0xFFED6C02));
    });

    test('neutral palette maintains proper ordering (lighter values have higher numbers)', () {
      expect(AppColors.neutral10.computeLuminance(),
             lessThan(AppColors.neutral20.computeLuminance()));
      expect(AppColors.neutral20.computeLuminance(),
             lessThan(AppColors.neutral30.computeLuminance()));
      expect(AppColors.neutral80.computeLuminance(),
             lessThan(AppColors.neutral90.computeLuminance()));
    });
  });

  group('AppShapes', () {
    test('shape scale tokens are defined correctly', () {
      expect(AppShapes.none, 0);
      expect(AppShapes.extraSmall, 4);
      expect(AppShapes.small, 8);
      expect(AppShapes.medium, 12);
      expect(AppShapes.large, 16);
      expect(AppShapes.extraLarge, 28);
      expect(AppShapes.full, 9999);
    });
  });

  group('AppSpacing', () {
    test('spacing scale is defined correctly', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 12);
      expect(AppSpacing.lg, 16);
      expect(AppSpacing.xl, 24);
      expect(AppSpacing.xxl, 32);
      expect(AppSpacing.xxxl, 48);
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
      expect(lightTheme.scaffoldBackgroundColor, AppColors.background);
    });

    test('has correct color scheme', () {
      expect(lightTheme.colorScheme.primary, AppColors.primary);
      expect(lightTheme.colorScheme.onPrimary, AppColors.onPrimary);
      expect(lightTheme.colorScheme.error, AppColors.error);
    });

    test('appbar theme is configured correctly', () {
      expect(lightTheme.appBarTheme.elevation, 0);
      expect(lightTheme.appBarTheme.backgroundColor, AppColors.surface);
      expect(lightTheme.appBarTheme.centerTitle, isFalse);
    });

    test('card theme has no elevation', () {
      expect(lightTheme.cardTheme.elevation, 0);
      expect(lightTheme.cardTheme.color, AppColors.surfaceContainerLowest);
    });

    test('elevated button theme is configured correctly', () {
      final buttonStyle = lightTheme.elevatedButtonTheme.style!;
      expect(
        buttonStyle.backgroundColor?.resolve({}),
        AppColors.primary,
      );
    });

    test('bottom navigation bar theme is configured correctly', () {
      expect(
        lightTheme.bottomNavigationBarTheme.backgroundColor,
        AppColors.surfaceContainerLowest,
      );
      expect(
        lightTheme.bottomNavigationBarTheme.selectedItemColor,
        AppColors.primary,
      );
    });

    test('text theme has correct heading styles', () {
      expect(lightTheme.textTheme.headlineLarge?.fontSize, 32);
      expect(lightTheme.textTheme.headlineMedium?.fontSize, 28);
      expect(lightTheme.textTheme.headlineSmall?.fontSize, 24);
    });

    test('text theme has correct body styles', () {
      expect(lightTheme.textTheme.bodyLarge?.fontSize, 16);
      expect(lightTheme.textTheme.bodyMedium?.fontSize, 14);
      expect(lightTheme.textTheme.bodySmall?.fontSize, 12);
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
      expect(darkTheme.scaffoldBackgroundColor, AppColors.surfaceDark);
    });

    test('has correct color scheme', () {
      expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
      expect(darkTheme.colorScheme.onPrimary, AppColors.onPrimaryDark);
    });

    test('appbar theme uses dark background', () {
      expect(darkTheme.appBarTheme.backgroundColor, AppColors.surfaceDark);
      expect(darkTheme.appBarTheme.foregroundColor, AppColors.onSurfaceDark);
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
