/// OCR 서비스
///
/// 이미지에서 텍스트를 추출하고 AI로 요약하는 기능을 제공합니다.
///
/// 사용하는 외부 서비스:
/// - Google Vision API (OCR): Supabase Edge Function(ocr-image)을 통해 호출
/// - AI 요약: Supabase Edge Function(summarize-text)을 통해 호출
library;

import 'dart:convert';
import 'dart:typed_data';
import '../core/supabase.dart';

/// OCR 및 텍스트 요약 기능을 제공하는 서비스 클래스
class OcrService {
  /// 이미지에서 텍스트를 추출합니다 (OCR).
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 이미지를 Base64로 인코딩하여 Edge Function에 전송하고,
  /// Google Vision API를 통해 텍스트를 추출합니다.
  ///
  /// 반환값: 추출된 텍스트 문자열
  /// 예외: OCR 처리 실패 시 Exception 발생
  Future<String> extractText(Uint8List imageBytes) async {
    // 이미지를 Base64로 인코딩하여 HTTP 전송 가능하게 변환
    final base64Image = base64Encode(imageBytes);

    final response = await supabase.functions.invoke(
      'ocr-image',
      body: {
        'imageBase64': base64Image,
      },
    );

    if (response.data == null) {
      throw Exception('OCR 처리에 실패했습니다');
    }

    return response.data['text'] as String? ?? '';
  }

  /// 텍스트를 AI를 사용하여 요약합니다.
  ///
  /// [text] 요약할 원본 텍스트
  ///
  /// 빈 텍스트의 경우 빈 문자열을 반환합니다.
  ///
  /// 반환값: 요약된 텍스트
  /// 예외: 요약 처리 실패 시 Exception 발생
  Future<String> summarizeText(String text) async {
    if (text.trim().isEmpty) return '';

    final response = await supabase.functions.invoke(
      'summarize-text',
      body: {
        'text': text,
      },
    );

    if (response.data == null) {
      throw Exception('요약 처리에 실패했습니다');
    }

    return response.data['summary'] as String? ?? '';
  }

  /// 이미지에서 텍스트를 추출하고 요약까지 수행합니다.
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 1. OCR로 이미지에서 텍스트 추출
  /// 2. 추출된 텍스트를 AI로 요약
  ///
  /// 반환값: 원본 텍스트와 요약을 포함한 OcrResult 객체
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    final extractedText = await extractText(imageBytes);

    // 추출된 텍스트가 없으면 빈 결과 반환
    if (extractedText.isEmpty) {
      return OcrResult(
        originalText: '',
        summary: '',
      );
    }

    final summary = await summarizeText(extractedText);

    return OcrResult(
      originalText: extractedText,
      summary: summary,
    );
  }
}

/// OCR 처리 결과를 담는 클래스
class OcrResult {
  /// OCR로 추출된 원본 텍스트
  final String originalText;

  /// AI가 생성한 요약 텍스트
  final String summary;

  OcrResult({
    required this.originalText,
    required this.summary,
  });
}
