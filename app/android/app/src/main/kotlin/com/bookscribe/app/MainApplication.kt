package com.bookscribe.app

import co.ab180.airbridge.flutter.AirbridgeFlutter
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Airbridge SDK 초기화
        AirbridgeFlutter.initializeSDK(
            this,
            "bookscribe",
            "810a3aa6d6734067a5eaa77c7fd84861"
        )
    }
}
