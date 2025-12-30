/// 개발 환경 진입점
///
/// 개발계 앱을 실행합니다.
/// Bundle ID: com.bookscribe.app.dev
library;

import 'core/env_config.dart';
import 'main_common.dart';

Future<void> main() async {
  await runAppWithEnv(EnvConfig.dev);
}
