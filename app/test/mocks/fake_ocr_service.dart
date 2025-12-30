/// Fake OcrService for testing
///
/// OcrNotifier 테스트를 위한 Fake 구현체입니다.
/// 실제 Google Vision API 호출 없이 다양한 시나리오를 테스트할 수 있습니다.
library;

import 'dart:typed_data';
import 'package:bookscribe/services/ocr_service.dart';

/// 테스트용 Fake OcrService
class FakeOcrService implements IOcrService {
  /// 반환할 텍스트 결과
  String extractedText = '';

  /// 에러 시뮬레이션
  Exception? extractTextError;
  Exception? processImageError;

  /// 호출 추적
  int extractTextCallCount = 0;
  int processImageCallCount = 0;

  /// 마지막 호출 시 전달된 이미지 바이트
  Uint8List? lastImageBytes;

  FakeOcrService();

  void reset() {
    extractedText = '';
    extractTextError = null;
    processImageError = null;
    extractTextCallCount = 0;
    processImageCallCount = 0;
    lastImageBytes = null;
  }

  @override
  Future<String> extractText(Uint8List imageBytes) async {
    extractTextCallCount++;
    lastImageBytes = imageBytes;

    if (extractTextError != null) {
      throw extractTextError!;
    }

    return extractedText;
  }

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    processImageCallCount++;
    lastImageBytes = imageBytes;

    if (processImageError != null) {
      throw processImageError!;
    }

    return OcrResult(originalText: extractedText);
  }
}
