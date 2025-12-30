/// 운영 환경 진입점
///
/// 운영계 앱을 실행합니다.
/// Bundle ID: com.bookscribe.app
library;

import 'core/env_config.dart';
import 'main_common.dart';

Future<void> main() async {
  await runAppWithEnv(EnvConfig.prod);
}
