/// 언어 설정 상태 관리 Provider
///
/// 이 파일은 앱의 언어 설정을 관리합니다.
/// SharedPreferences를 사용하여 사용자의 언어 설정을 영구 저장합니다.
///
/// 지원하는 언어:
/// - ko: 한국어
/// - en: 영어
library;

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱에서 지원하는 언어 열거형
enum AppLanguage {
  /// 한국어
  ko,

  /// 영어
  en,
}

/// 언어 상태를 관리하는 StateNotifier
///
/// 앱 시작 시 SharedPreferences에서 저장된 언어 설정을 불러오고,
/// 첫 실행 시에는 기기 언어 설정을 감지하여 자동으로 설정합니다.
/// 언어 변경 시 설정을 저장합니다.
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(_getDeviceLanguage()) {
    _loadLanguage();
  }

  /// SharedPreferences 저장 키
  static const _key = 'language';

  /// 기기의 언어 설정을 감지하여 AppLanguage로 반환합니다.
  ///
  /// 한국어(ko)가 아닌 경우 영어(en)를 기본값으로 반환합니다.
  static AppLanguage _getDeviceLanguage() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'ko') {
      return AppLanguage.ko;
    }
    return AppLanguage.en;
  }

  /// 저장된 언어 설정을 불러옵니다.
  ///
  /// 저장된 값이 없으면 기기 언어 설정을 유지합니다.
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = AppLanguage.values.firstWhere(
        (e) => e.name == value,
        orElse: () => _getDeviceLanguage(),
      );
    }
    // 첫 실행 시에는 기기 언어가 이미 super()에서 설정됨
  }

  /// 언어를 변경하고 저장합니다.
  ///
  /// [language] 설정할 언어
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
  }

  /// Flutter의 Locale로 변환합니다.
  ///
  /// MaterialApp의 locale 파라미터에 전달하기 위해 사용합니다.
  Locale get locale => Locale(state.name);
}

/// 언어 상태를 관리하는 Provider
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
