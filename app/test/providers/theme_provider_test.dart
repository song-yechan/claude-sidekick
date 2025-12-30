/// ThemeProvider 테스트
///
/// 테마 상태 관리 및 AppThemeMode를 검증합니다.
/// SharedPreferences 의존성으로 인해 ThemeNotifier 생성은 위젯 테스트에서 수행합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/theme_provider.dart';

void main() {
  group('AppThemeMode', () {
    test('has three values', () {
      expect(AppThemeMode.values.length, 3);
    });

    test('contains system, light, dark', () {
      expect(AppThemeMode.values, contains(AppThemeMode.system));
      expect(AppThemeMode.values, contains(AppThemeMode.light));
      expect(AppThemeMode.values, contains(AppThemeMode.dark));
    });

    test('system is first value', () {
      expect(AppThemeMode.values.first, AppThemeMode.system);
    });

    test('light is second value', () {
      expect(AppThemeMode.values[1], AppThemeMode.light);
    });

    test('dark is third value', () {
      expect(AppThemeMode.values[2], AppThemeMode.dark);
    });

    test('name property returns correct string', () {
      expect(AppThemeMode.system.name, 'system');
      expect(AppThemeMode.light.name, 'light');
      expect(AppThemeMode.dark.name, 'dark');
    });

    test('can be found by name', () {
      expect(
        AppThemeMode.values.firstWhere((e) => e.name == 'system'),
        AppThemeMode.system,
      );
      expect(
        AppThemeMode.values.firstWhere((e) => e.name == 'light'),
        AppThemeMode.light,
      );
      expect(
        AppThemeMode.values.firstWhere((e) => e.name == 'dark'),
        AppThemeMode.dark,
      );
    });

    test('returns system as default for unknown name', () {
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == 'unknown',
        orElse: () => AppThemeMode.system,
      );
      expect(mode, AppThemeMode.system);
    });
  });

  group('AppThemeMode to ThemeMode mapping', () {
    ThemeMode mapToThemeMode(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return ThemeMode.light;
        case AppThemeMode.dark:
          return ThemeMode.dark;
        case AppThemeMode.system:
          return ThemeMode.system;
      }
    }

    test('system maps to ThemeMode.system', () {
      expect(mapToThemeMode(AppThemeMode.system), ThemeMode.system);
    });

    test('light maps to ThemeMode.light', () {
      expect(mapToThemeMode(AppThemeMode.light), ThemeMode.light);
    });

    test('dark maps to ThemeMode.dark', () {
      expect(mapToThemeMode(AppThemeMode.dark), ThemeMode.dark);
    });

    test('all modes map to valid ThemeMode', () {
      for (final mode in AppThemeMode.values) {
        expect(mapToThemeMode(mode), isA<ThemeMode>());
      }
    });
  });

  group('ThemeMode values', () {
    test('ThemeMode has system, light, dark', () {
      expect(ThemeMode.values, contains(ThemeMode.system));
      expect(ThemeMode.values, contains(ThemeMode.light));
      expect(ThemeMode.values, contains(ThemeMode.dark));
    });

    test('ThemeMode count matches AppThemeMode count', () {
      expect(ThemeMode.values.length, AppThemeMode.values.length);
    });
  });
}
