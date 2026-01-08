/// 공통 앱 초기화 로직
///
/// main_dev.dart와 main_prod.dart에서 공유하는 초기화 코드입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/env_config.dart';
import 'core/theme.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

/// 환경에 따라 앱을 초기화하고 실행합니다.
Future<void> runAppWithEnv(EnvConfig envConfig) async {
  // 전역 환경 설정 초기화
  currentEnv = envConfig;

  // 네이티브 스플래시 유지 (Flutter 엔진 초기화 동안만)
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables
  await dotenv.load(fileName: envConfig.envFileName);

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Note: Airbridge SDK는 네이티브에서 초기화됨
  // iOS: AppDelegate.swift, Android: MainApplication.kt

  // 환경 로그 출력 (개발 환경에서만)
  if (envConfig.isDev) {
    debugPrint('🔧 Running in ${envConfig.name} environment');
    debugPrint('🔧 Supabase URL: $supabaseUrl');
  }

  // 네이티브 스플래시 제거 → Flutter 스플래시로 전환
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: BookScanApp(),
    ),
  );
}

class BookScanApp extends ConsumerWidget {
  const BookScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appThemeMode = ref.watch(themeProvider);

    // AppThemeMode를 ThemeMode로 변환
    final themeMode = switch (appThemeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: currentEnv.appName,
      debugShowCheckedModeBanner: currentEnv.isDev,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
