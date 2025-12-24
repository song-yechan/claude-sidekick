/// 에러 처리 유틸리티
///
/// 앱에서 발생하는 에러를 사용자 친화적인 메시지로 변환합니다.
/// 기술적인 에러 메시지 대신 사용자가 이해하기 쉬운 한글 메시지를 제공합니다.
library;

/// 에러 객체를 사용자 친화적 메시지로 변환합니다.
///
/// [error] 변환할 에러 객체
///
/// 에러 유형별로 적절한 한글 메시지를 반환합니다:
/// - 네트워크 에러: 연결 확인 안내
/// - 인증 에러: 로그인 필요 안내
/// - 서버 에러: 재시도 안내
/// - Rate Limit: 대기 안내
/// - 기타: 일반적인 오류 메시지
String getUserFriendlyErrorMessage(Object error) {
  final errorString = error.toString().toLowerCase();

  // Rate Limit 에러 (429)
  if (errorString.contains('429') ||
      errorString.contains('rate limit') ||
      errorString.contains('too many requests')) {
    return '요청이 너무 많습니다.\n잠시 후 다시 시도해주세요';
  }

  // 네트워크 관련 에러
  if (errorString.contains('socketexception') ||
      errorString.contains('failed host lookup') ||
      errorString.contains('network is unreachable') ||
      errorString.contains('connection refused') ||
      errorString.contains('connection timed out') ||
      errorString.contains('no internet') ||
      errorString.contains('clientexception')) {
    return '네트워크 연결을 확인해주세요';
  }

  // 인증 관련 에러
  if (errorString.contains('unauthorized') ||
      errorString.contains('401')) {
    return '로그인이 필요합니다';
  }

  // 권한 에러
  if (errorString.contains('forbidden') ||
      errorString.contains('403')) {
    return '접근 권한이 없습니다';
  }

  // 서버 에러
  if (errorString.contains('500') ||
      errorString.contains('502') ||
      errorString.contains('503') ||
      errorString.contains('server error')) {
    return '서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요';
  }

  // 타임아웃
  if (errorString.contains('timeout')) {
    return '요청 시간이 초과되었습니다.\n네트워크 상태를 확인해주세요';
  }

  // 이미지 크기 에러
  if (errorString.contains('too large') ||
      errorString.contains('size limit') ||
      errorString.contains('payload')) {
    return '이미지 크기가 너무 큽니다.\n다른 이미지를 선택해주세요';
  }

  // 기본 메시지
  return '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요';
}
