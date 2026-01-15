/// 테스트용 앱 래퍼
///
/// L10n을 지원하는 테스트용 MaterialApp 래퍼입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bookscribe/l10n/app_localizations.dart';

/// 테스트용 MaterialApp 래퍼
///
/// L10n을 지원하는 MaterialApp으로 위젯을 감쌉니다.
class TestApp extends StatelessWidget {
  final Widget child;
  final Locale locale;

  const TestApp({
    super.key,
    required this.child,
    this.locale = const Locale('ko'),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }
}

/// 테스트용 MaterialApp 래퍼 (Scaffold 없이)
class TestAppNoScaffold extends StatelessWidget {
  final Widget child;
  final Locale locale;

  const TestAppNoScaffold({
    super.key,
    required this.child,
    this.locale = const Locale('ko'),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,
      home: child,
    );
  }
}
