/// OCR 서비스
///
/// 이미지에서 텍스트를 추출하는 기능을 제공합니다.
///
/// 사용하는 외부 서비스:
/// - Google Vision API (OCR): Supabase Edge Function(ocr-image)을 통해 호출
library;

import 'dart:convert';
import 'dart:typed_data';
import '../core/supabase.dart';

/// OcrService 인터페이스
///
/// 테스트에서 Mock 구현체를 사용할 수 있도록 인터페이스를 정의합니다.
abstract class IOcrService {
  Future<String> extractText(Uint8List imageBytes);
  Future<OcrResult> processImage(Uint8List imageBytes);
}

/// OCR 기능을 제공하는 서비스 클래스
class OcrService implements IOcrService {
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

    print('📷 OCR: Calling Edge Function...');
    print('📷 OCR: Image base64 length: ${base64Image.length}');

    final response = await supabase.functions.invoke(
      'ocr-image',
      body: {
        'imageBase64': base64Image,
      },
    );

    print('📷 OCR: Response status: ${response.status}');
    print('📷 OCR: Response data: ${response.data}');

    // 에러 상태 코드 확인
    if (response.status >= 400) {
      final errorMsg = response.data?['error'] ?? response.data?['details'] ?? 'Unknown error';
      throw Exception('$errorMsg (${response.status})');
    }

    if (response.data == null) {
      throw Exception('OCR 처리에 실패했습니다');
    }

    return response.data['text'] as String? ?? '';
  }

  /// 이미지에서 텍스트를 추출합니다.
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 반환값: 추출된 텍스트를 포함한 OcrResult 객체
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
