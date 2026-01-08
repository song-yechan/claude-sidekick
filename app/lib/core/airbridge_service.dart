/// Airbridge SDK 서비스
///
/// MMP(Mobile Measurement Partner) 연동을 위한 이벤트 트래킹 기능을 제공합니다.
/// SDK 초기화는 네이티브 코드(iOS: AppDelegate.swift, Android: MainApplication.kt)에서 수행됩니다.
library;

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';

/// Airbridge 서비스 클래스
///
/// 이벤트 트래킹, 사용자 설정 등의 기능을 제공합니다.
/// SDK 초기화는 네이티브에서 처리되므로 Dart에서는 별도 초기화가 필요하지 않습니다.
class AirbridgeService {
  AirbridgeService._();

  /// 회원가입 이벤트 트래킹
  static void trackSignUp({required String method}) {
    Airbridge.trackEvent(
      category: AirbridgeCategory.SIGN_UP,
      semanticAttributes: {
        AirbridgeAttribute.ACTION: method, // 'apple', 'google', 'email'
      },
    );
  }

  /// 로그인 이벤트 트래킹
  static void trackSignIn({required String method}) {
    Airbridge.trackEvent(
      category: AirbridgeCategory.SIGN_IN,
      semanticAttributes: {
        AirbridgeAttribute.ACTION: method,
      },
    );
  }

  /// 로그아웃 이벤트 트래킹
  static void trackSignOut() {
    Airbridge.trackEvent(category: AirbridgeCategory.SIGN_OUT);
  }

  /// 책 추가 이벤트 트래킹
  static void trackBookAdded({
    required String bookTitle,
    String? isbn,
    String? author,
  }) {
    Airbridge.trackEvent(
      category: 'book_added',
      semanticAttributes: {
        AirbridgeAttribute.LABEL: bookTitle,
      },
      customAttributes: {
        if (isbn != null) 'isbn': isbn,
        if (author != null) 'author': author,
      },
    );
  }

  /// 노트 생성 이벤트 트래킹
  static void trackNoteCreated({
    required String bookId,
    required bool usedOcr,
  }) {
    Airbridge.trackEvent(
      category: 'note_created',
      customAttributes: {
        'book_id': bookId,
        'used_ocr': usedOcr,
      },
    );
  }

  /// OCR 사용 이벤트 트래킹
  static void trackOcrUsed({required bool success}) {
    Airbridge.trackEvent(
      category: 'ocr_used',
      customAttributes: {
        'success': success,
      },
    );
  }

  /// 온보딩 완료 이벤트 트래킹
  static void trackOnboardingCompleted({
    List<String>? goals,
    String? readingFrequency,
  }) {
    Airbridge.trackEvent(
      category: AirbridgeCategory.COMPLETE_TUTORIAL,
      customAttributes: {
        if (goals != null && goals.isNotEmpty) 'goals': goals.join(','),
        if (readingFrequency != null) 'reading_frequency': readingFrequency,
      },
    );
  }

  /// 책 검색 이벤트 트래킹
  static void trackBookSearched({required String query}) {
    Airbridge.trackEvent(
      category: AirbridgeCategory.SEARCH_RESULTS_VIEWED,
      semanticAttributes: {
        AirbridgeAttribute.QUERY: query,
      },
    );
  }

  /// 홈 화면 조회 이벤트 트래킹
  static void trackHomeViewed() {
    Airbridge.trackEvent(category: AirbridgeCategory.HOME_VIEWED);
  }

  /// 커스텀 이벤트 트래킹
  static void trackCustomEvent({
    required String category,
    String? action,
    String? label,
    double? value,
    Map<String, dynamic>? customAttributes,
  }) {
    final semanticAttrs = <String, dynamic>{};
    if (action != null) semanticAttrs[AirbridgeAttribute.ACTION] = action;
    if (label != null) semanticAttrs[AirbridgeAttribute.LABEL] = label;
    if (value != null) semanticAttrs[AirbridgeAttribute.VALUE] = value;

    Airbridge.trackEvent(
      category: category,
      semanticAttributes: semanticAttrs.isNotEmpty ? semanticAttrs : null,
      customAttributes: customAttributes,
    );
  }

  /// 사용자 ID 설정 (로그인 시)
  static void setUserId(String userId) {
    Airbridge.setUserID(userId);
  }

  /// 사용자 정보 초기화 (로그아웃 시)
  static void clearUser() {
    Airbridge.clearUser();
  }

  /// 딥링크 리스너 설정
  static void setDeeplinkListener(void Function(String) onReceived) {
    Airbridge.setOnDeeplinkReceived(onReceived);
  }

  /// 어트리뷰션 리스너 설정
  static void setAttributionListener(
    void Function(Map<String, String>) onReceived,
  ) {
    Airbridge.setOnAttributionReceived(onReceived);
  }
}
