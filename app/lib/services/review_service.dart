/// 인앱 리뷰 요청 서비스
///
/// 적절한 시점에 사용자에게 앱 스토어 리뷰를 요청합니다.
/// SharedPreferences를 사용하여 리뷰 요청 이력을 추적합니다.
///
/// 리뷰 요청 트리거 조건:
/// - 책 2권 이상 저장 시
/// - 노트 3개 이상 작성 시
library;

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 리뷰 요청 상태를 추적하는 키
class _ReviewKeys {
  static const String hasRequestedReview = 'has_requested_review';
  static const String lastReviewRequestDate = 'last_review_request_date';
}

/// 인앱 리뷰 서비스 인터페이스
abstract class IReviewService {
  /// 책 저장 시 리뷰 요청 가능 여부 확인 및 요청
  Future<void> checkAndRequestReviewForBooks(int bookCount);

  /// 노트 저장 시 리뷰 요청 가능 여부 확인 및 요청
  Future<void> checkAndRequestReviewForNotes(int noteCount);

  /// 리뷰 요청 가능 여부 확인
  Future<bool> canRequestReview();

  /// 리뷰 요청 이력 초기화 (테스트용)
  Future<void> resetReviewStatus();
}

/// 인앱 리뷰 서비스 구현
class ReviewService implements IReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  /// 리뷰 요청에 필요한 최소 책 수
  static const int minBooksForReview = 2;

  /// 리뷰 요청에 필요한 최소 노트 수
  static const int minNotesForReview = 3;

  /// 책 저장 시 리뷰 요청 가능 여부 확인 및 요청
  ///
  /// [bookCount] 현재 사용자의 총 책 수
  /// 책이 2권 이상이고 아직 리뷰를 요청하지 않았다면 리뷰 요청
  @override
  Future<void> checkAndRequestReviewForBooks(int bookCount) async {
    if (bookCount >= minBooksForReview) {
      await _requestReviewIfEligible();
    }
  }

  /// 노트 저장 시 리뷰 요청 가능 여부 확인 및 요청
  ///
  /// [noteCount] 현재 사용자의 총 노트 수
  /// 노트가 3개 이상이고 아직 리뷰를 요청하지 않았다면 리뷰 요청
  @override
  Future<void> checkAndRequestReviewForNotes(int noteCount) async {
    if (noteCount >= minNotesForReview) {
      await _requestReviewIfEligible();
    }
  }

  /// 리뷰 요청 가능 여부 확인
  ///
  /// 다음 조건을 모두 만족해야 true 반환:
  /// - 아직 리뷰를 요청하지 않았거나 마지막 요청으로부터 90일 이상 경과
  /// - 기기에서 인앱 리뷰가 지원됨
  @override
  Future<bool> canRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool(_ReviewKeys.hasRequestedReview) ?? false;

    // 이미 리뷰를 요청한 경우
    if (hasRequested) {
      // 마지막 요청 날짜 확인 (90일 이후 재요청 가능)
      final lastRequestDateStr =
          prefs.getString(_ReviewKeys.lastReviewRequestDate);
      if (lastRequestDateStr != null) {
        final lastRequestDate = DateTime.parse(lastRequestDateStr);
        final daysSinceLastRequest =
            DateTime.now().difference(lastRequestDate).inDays;
        if (daysSinceLastRequest < 90) {
          return false;
        }
      } else {
        return false;
      }
    }

    // 인앱 리뷰 가능 여부 확인
    return await _inAppReview.isAvailable();
  }

  /// 리뷰 요청 이력 초기화 (테스트용)
  @override
  Future<void> resetReviewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ReviewKeys.hasRequestedReview);
    await prefs.remove(_ReviewKeys.lastReviewRequestDate);
  }

  /// 조건 충족 시 리뷰 요청
  Future<void> _requestReviewIfEligible() async {
    final canRequest = await canRequestReview();
    if (!canRequest) {
      if (kDebugMode) print('📝 ReviewService: 리뷰 요청 조건 미충족');
      return;
    }

    try {
      if (kDebugMode) print('📝 ReviewService: 인앱 리뷰 요청 중...');
      await _inAppReview.requestReview();

      // 리뷰 요청 이력 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_ReviewKeys.hasRequestedReview, true);
      await prefs.setString(
          _ReviewKeys.lastReviewRequestDate, DateTime.now().toIso8601String());

      if (kDebugMode) print('📝 ReviewService: 인앱 리뷰 요청 완료');
    } catch (e) {
      if (kDebugMode) print('📝 ReviewService: 인앱 리뷰 요청 실패 - $e');
    }
  }
}
