/// OCR 서비스
///
/// 이미지에서 텍스트를 추출하는 기능을 제공합니다.
/// Google Cloud Vision API를 사용하여 높은 정확도의 OCR을 제공합니다.
///
/// 사용하는 외부 서비스:
/// - Google Vision API: Supabase Edge Function(ocr-image)을 통해 호출
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/supabase.dart';
import '../core/airbridge_service.dart';

/// OcrService 인터페이스
///
/// 테스트에서 Mock 구현체를 사용할 수 있도록 인터페이스를 정의합니다.
abstract class IOcrService {
  Future<String> extractText(Uint8List imageBytes);
  Future<OcrResult> processImage(Uint8List imageBytes);
}

/// OCR 기능을 제공하는 서비스 클래스
///
/// Google Cloud Vision API를 사용하여 텍스트를 추출합니다.
class OcrService implements IOcrService {
  /// 이미지에서 텍스트를 추출합니다 (OCR).
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 반환값: 추출된 텍스트 문자열
  /// 예외: OCR 처리 실패 시 Exception 발생
  @override
  Future<String> extractText(Uint8List imageBytes) async {
    if (kDebugMode) print('📷 OCR: Starting text extraction with Cloud Vision...');

    final base64Image = base64Encode(imageBytes);
    if (kDebugMode) print('📷 OCR: Image base64 length: ${base64Image.length}');

    final response = await supabase.functions.invoke(
      'ocr-image',
      body: {
        'imageBase64': base64Image,
      },
    );

    if (kDebugMode) print('📷 OCR: Cloud Vision response status: ${response.status}');

    if (response.status >= 400) {
      final errorMsg = response.data?['error'] ?? response.data?['details'] ?? 'Unknown error';
      throw Exception('$errorMsg (${response.status})');
    }

    if (response.data == null) {
      throw Exception('OCR 처리에 실패했습니다');
    }

    final text = response.data['text'] as String? ?? '';
    if (kDebugMode) print('📷 OCR: Cloud Vision extracted ${text.length} chars');

    // Airbridge 이벤트 트래킹 (성공)
    AirbridgeService.trackOcrUsed(success: true);

    return text;
  }

  /// 이미지에서 텍스트를 추출합니다.
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 반환값: 추출된 텍스트를 포함한 OcrResult 객체
  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    final extractedText = await extractText(imageBytes);

    return OcrResult(
      originalText: extractedText,
    );
  }
}

/// OCR 처리 결과를 담는 클래스
class OcrResult {
  /// OCR로 추출된 원본 텍스트
  final String originalText;

  OcrResult({
    required this.originalText,
  });
}
