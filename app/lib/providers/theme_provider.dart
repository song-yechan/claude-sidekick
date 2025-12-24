/// 테마(다크모드/라이트모드) 상태 관리 Provider
///
/// 이 파일은 앱의 테마 모드를 관리합니다.
/// SharedPreferences를 사용하여 사용자의 테마 설정을 영구 저장합니다.
///
/// 지원하는 테마 모드:
/// - system: 시스템 설정을 따름
/// - light: 항상 라이트 모드
/// - dark: 항상 다크 모드
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱에서 사용하는 테마 모드 열거형
enum AppThemeMode {
  /// 시스템 설정을 따름
  system,

  /// 항상 라이트 모드
  light,

  /// 항상 다크 모드
  dark,
}

/// 테마 상태를 관리하는 StateNotifier
///
/// 앱 시작 시 SharedPreferences에서 저장된 테마 설정을 불러오고,
/// 테마 변경 시 설정을 저장합니다.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  /// SharedPreferences 저장 키
  static const _key = 'theme_mode';

  /// 저장된 테마 설정을 불러옵니다.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  /// 테마 모드를 변경하고 저장합니다.
  ///
  /// [mode] 설정할 테마 모드
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Flutter의 ThemeMode로 변환합니다.
  ///
  /// MaterialApp의 themeMode 파라미터에 전달하기 위해 사용합니다.
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// 테마 상태를 관리하는 Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
