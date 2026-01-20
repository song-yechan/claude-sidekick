/// 넛지(알림 강도) 모델
///
/// 스마트 넛지 시스템의 레벨 및 메시지 정책을 정의합니다.
library;

/// 넛지 레벨 열거형
///
/// 비활성 기간에 따라 알림 강도가 달라집니다.
enum NudgeLevel {
  /// 정상 (0~1일 비활성)
  normal,

  /// 약한 넛지 (2~3일 비활성)
  gentle,

  /// 중간 넛지 (4~6일 비활성)
  moderate,

  /// 강한 넛지 (7일+ 비활성)
  strong,
}

/// 넛지 레벨 계산 및 관련 유틸리티
extension NudgeLevelExtension on NudgeLevel {
  /// 비활성 일수에 따른 넛지 레벨 계산
  static NudgeLevel fromInactiveDays(int days) {
    if (days <= 1) return NudgeLevel.normal;
    if (days <= 3) return NudgeLevel.gentle;
    if (days <= 6) return NudgeLevel.moderate;
    return NudgeLevel.strong;
  }

  /// 해당 레벨의 알림 횟수 (일당)
  int get dailyNotificationCount {
    switch (this) {
      case NudgeLevel.normal:
      case NudgeLevel.gentle:
      case NudgeLevel.moderate:
      case NudgeLevel.strong:
        return 1;
    }
  }

  /// 디버그용 문자열 표현
  String get debugLabel {
    switch (this) {
      case NudgeLevel.normal:
        return 'Normal (0-1 days)';
      case NudgeLevel.gentle:
        return 'Gentle (2-3 days)';
      case NudgeLevel.moderate:
        return 'Moderate (4-6 days)';
      case NudgeLevel.strong:
        return 'Strong (7+ days)';
    }
  }
}

/// 알림 메시지 키 (L10n 키로 사용)
///
/// 넛지 레벨에 따른 알림 메시지를 제공합니다.
class NudgeMessageKeys {
  NudgeMessageKeys._();

  /// 레벨별 알림 제목 키
  static String titleKey(NudgeLevel level) {
    return 'notification_title_reading_reminder';
  }

  /// 레벨별 알림 본문 키
  static String bodyKey(NudgeLevel level) {
    switch (level) {
      case NudgeLevel.normal:
        return 'notification_message_normal';
      case NudgeLevel.gentle:
        return 'notification_message_gentle';
      case NudgeLevel.moderate:
        return 'notification_message_moderate';
      case NudgeLevel.strong:
        return 'notification_message_strong';
    }
  }
}
