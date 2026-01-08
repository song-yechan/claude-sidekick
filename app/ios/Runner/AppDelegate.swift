import Flutter
import UIKit
import airbridge_flutter_sdk

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Airbridge SDK 초기화
    AirbridgeFlutter.initializeSDK(
      name: "bookscribe",
      token: "810a3aa6d6734067a5eaa77c7fd84861"
    )

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Universal Links 처리
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    AirbridgeFlutter.trackDeeplink(userActivity: userActivity)
    return true
  }

  // URL Scheme 딥링크 처리
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    AirbridgeFlutter.trackDeeplink(url: url)
    return true
  }
}
