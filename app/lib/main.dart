/// 기본 진입점 (운영 환경)
///
/// 하위 호환성을 위해 기존 main.dart를 유지합니다.
/// Flutter flavor를 사용하지 않고 직접 실행할 경우 운영 환경으로 실행됩니다.
///
/// 권장 사용법:
/// - 개발 환경: flutter run --flavor dev -t lib/main_dev.dart
/// - 운영 환경: flutter run --flavor prod -t lib/main_prod.dart
library;

import 'core/env_config.dart';
import 'main_common.dart';

Future<void> main() async {
  // 기본값으로 운영 환경 사용 (하위 호환성)
  await runAppWithEnv(EnvConfig.prod);
}
