import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  // 스플래시 화면 유지 (앱 초기화 완료까지)
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  print('🔌 Supabase URL: $supabaseUrl');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: BookScanApp(),
    ),
  );
}

class BookScanApp extends ConsumerStatefulWidget {
  const BookScanApp({super.key});

  @override
  ConsumerState<BookScanApp> createState() => _BookScanAppState();
}

class _BookScanAppState extends ConsumerState<BookScanApp> {
  bool _splashRemoved = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appThemeMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    // 인증 상태 확인 완료 후 스플래시 제거
    if (!_splashRemoved && !authState.isLoading) {
      _splashRemoved = true;
      FlutterNativeSplash.remove();
    }

    // AppThemeMode를 ThemeMode로 변환
    final themeMode = switch (appThemeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'BookScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
