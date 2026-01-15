/// 에러 처리 유틸리티
///
/// 앱에서 발생하는 에러를 사용자 친화적인 메시지로 변환합니다.
/// 기술적인 에러 메시지 대신 사용자가 이해하기 쉬운 메시지를 제공합니다.
library;

import 'package:flutter/material.dart';
import 'theme.dart';

/// 에러 객체를 사용자 친화적 메시지로 변환합니다.
///
/// [context] BuildContext (L10n 접근용)
/// [error] 변환할 에러 객체
///
/// 에러 유형별로 적절한 메시지를 반환합니다:
/// - 네트워크 에러: 연결 확인 안내
/// - 인증 에러: 로그인 필요 안내
/// - 서버 에러: 재시도 안내
/// - Rate Limit: 대기 안내
/// - 기타: 일반적인 오류 메시지
String getUserFriendlyErrorMessage(BuildContext context, Object error) {
  final l10n = context.l10n;
  final errorString = error.toString().toLowerCase();

  // Rate Limit 에러 (429)
  if (errorString.contains('429') ||
      errorString.contains('rate limit') ||
      errorString.contains('too many requests')) {
    return l10n.error_tooManyRequests;
  }

  // 네트워크 관련 에러
  if (errorString.contains('socketexception') ||
      errorString.contains('failed host lookup') ||
      errorString.contains('network is unreachable') ||
      errorString.contains('connection refused') ||
      errorString.contains('connection timed out') ||
      errorString.contains('no internet') ||
      errorString.contains('clientexception')) {
    return l10n.error_network;
  }

  // 인증 관련 에러
  if (errorString.contains('unauthorized') ||
      errorString.contains('401')) {
    return l10n.auth_loginRequiredMessage;
  }

  // 권한 에러
  if (errorString.contains('forbidden') ||
      errorString.contains('403')) {
    return l10n.error_noPermission;
  }

  // 서버 에러
  if (errorString.contains('500') ||
      errorString.contains('502') ||
      errorString.contains('503') ||
      errorString.contains('server error')) {
    return l10n.error_serverError;
  }

  // 타임아웃
  if (errorString.contains('timeout')) {
    return l10n.error_timeout;
  }

  // 이미지 크기 에러
  if (errorString.contains('too large') ||
      errorString.contains('size limit') ||
      errorString.contains('payload')) {
    return l10n.ocr_imageTooLarge;
  }

  // 기본 메시지
  return l10n.error_temporaryError;
}
