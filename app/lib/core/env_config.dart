/// 환경 설정 관리 클래스
///
/// 개발계(dev)와 운영계(prod) 환경을 구분하여 관리합니다.
/// 각 환경별로 다른 Supabase 프로젝트, Bundle ID 등을 사용합니다.
library;

/// 앱 환경 타입
enum AppEnvironment {
  /// 개발 환경
  dev,

  /// 운영 환경
  prod,
}

/// 환경별 설정을 담는 클래스
class EnvConfig {
  /// 현재 환경
  final AppEnvironment environment;

  /// 앱 이름 (표시용)
  final String appName;

  /// 환경 설정 파일명
  final String envFileName;

  const EnvConfig._({
    required this.environment,
    required this.appName,
    required this.envFileName,
  });

  /// 개발 환경 설정
  static const dev = EnvConfig._(
    environment: AppEnvironment.dev,
    appName: 'BookScribe Dev',
    envFileName: '.env.dev',
  );

  /// 운영 환경 설정
  static const prod = EnvConfig._(
    environment: AppEnvironment.prod,
    appName: 'BookScribe',
    envFileName: '.env.prod',
  );

  /// 현재 환경이 개발 환경인지 확인
  bool get isDev => environment == AppEnvironment.dev;

  /// 현재 환경이 운영 환경인지 확인
  bool get isProd => environment == AppEnvironment.prod;

  /// 환경 이름 (로그용)
  String get name => switch (environment) {
        AppEnvironment.dev => 'Development',
        AppEnvironment.prod => 'Production',
      };
}

/// 전역 환경 설정 인스턴스
/// main_dev.dart 또는 main_prod.dart에서 초기화됩니다.
late EnvConfig currentEnv;
