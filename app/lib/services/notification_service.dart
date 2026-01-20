/// 알림 서비스
///
/// 로컬 알림 스케줄링 및 관리를 담당합니다.
/// flutter_local_notifications 패키지를 사용합니다.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/nudge.dart';
import '../models/streak.dart';

/// 알림 채널 ID
const String _channelId = 'reading_reminder';
const String _channelName = 'Reading Reminders';
const String _channelDesc = 'Daily reading reminder notifications';

/// 알림 ID
const int _dailyReminderNotificationId = 1;

/// 로컬 알림 서비스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    // 타임존 초기화
    tz_data.initializeTimeZones();

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    await _createNotificationChannel();

    _initialized = true;
  }

  /// Android 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 앱 열기 (추가 로직 필요시 여기에 구현)
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  /// 알림 권한 요청
  ///
  /// iOS에서는 명시적으로 권한을 요청해야 합니다.
  /// Android 13+에서도 런타임 권한이 필요합니다.
  Future<bool> requestPermission() async {
    // iOS 권한 요청
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    // Android 13+ 권한 요청
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? false;
    }

    return true;
  }

  /// 알림 권한 상태 확인
  Future<bool> hasPermission() async {
    // iOS
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final settings = await iosPlugin.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    // Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final result = await androidPlugin.areNotificationsEnabled();
      return result ?? true;
    }

    return true;
  }

  /// 일일 리마인더 알림 스케줄링
  ///
  /// [time] 알림을 받을 시간
  /// [title] 알림 제목
  /// [body] 알림 본문
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    // 기존 알림 취소
    await cancelDailyReminder();

    // 다음 알림 시간 계산
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 이미 지난 시간이면 다음 날로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 알림 상세 설정
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 매일 반복 알림 스케줄링
    await _notifications.zonedSchedule(
      _dailyReminderNotificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 스마트 넛지 알림 스케줄링
  ///
  /// 넛지 레벨과 스트릭 데이터를 기반으로 적절한 메시지로 알림을 설정합니다.
  Future<void> scheduleSmartNudge({
    required TimeOfDay time,
    required NudgeLevel level,
    required StreakData? streakData,
    required String Function(NudgeLevel level, int? days) messageGenerator,
  }) async {
    final title = '독서 시간'; // 또는 L10n에서 가져오기
    final body = messageGenerator(level, streakData?.currentStreak);

    await scheduleDailyReminder(
      time: time,
      title: title,
      body: body,
    );
  }

  /// 일일 리마인더 알림 취소
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(_dailyReminderNotificationId);
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 즉시 테스트 알림 표시 (디버그용)
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
