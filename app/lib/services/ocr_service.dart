/// OCR 서비스
///
/// 이미지에서 텍스트를 추출하는 기능을 제공합니다.
///
/// 전략:
/// 1. ML Kit (온디바이스) 우선 시도 - 빠르고 무료
/// 2. 실패 시 Cloud Vision API 폴백 - 더 정확함
///
/// 사용하는 외부 서비스:
/// - Google ML Kit (온디바이스 OCR)
/// - Google Vision API (클라우드 OCR): Supabase Edge Function(ocr-image)을 통해 호출
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../core/supabase.dart';

/// OcrService 인터페이스
///
/// 테스트에서 Mock 구현체를 사용할 수 있도록 인터페이스를 정의합니다.
abstract class IOcrService {
  Future<String> extractText(Uint8List imageBytes);
  Future<OcrResult> processImage(Uint8List imageBytes);
}

/// OCR 기능을 제공하는 서비스 클래스
///
/// ML Kit 온디바이스 OCR을 우선 사용하고,
/// 실패 시 Cloud Vision API로 폴백합니다.
class OcrService implements IOcrService {
  /// ML Kit 텍스트 인식기 (한글 + 라틴)
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.korean,
  );

  /// ML Kit 신뢰도 임계값 (이 값 미만이면 Cloud Vision 폴백)
  static const double _minConfidence = 0.5;

  /// 이미지에서 텍스트를 추출합니다 (OCR).
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  ///
  /// 1차: ML Kit (온디바이스) 시도
  /// 2차: 실패 시 Cloud Vision API 폴백
  ///
  /// 반환값: 추출된 텍스트 문자열
  /// 예외: OCR 처리 실패 시 Exception 발생
  @override
  Future<String> extractText(Uint8List imageBytes) async {
    print('📷 OCR: Starting text extraction...');

    // 1차: ML Kit 시도
    try {
      final mlKitResult = await _extractWithMlKit(imageBytes);

      if (mlKitResult.isValid) {
        print('📷 OCR: ML Kit succeeded (${mlKitResult.text.length} chars, confidence: ${mlKitResult.confidence.toStringAsFixed(2)})');
        return mlKitResult.text;
      }

      print('📷 OCR: ML Kit confidence too low (${mlKitResult.confidence.toStringAsFixed(2)}), falling back to Cloud Vision');
    } catch (e) {
      print('📷 OCR: ML Kit failed: $e, falling back to Cloud Vision');
    }

    // 2차: Cloud Vision API 폴백
    return _extractWithCloudVision(imageBytes);
  }

  /// ML Kit (온디바이스)로 텍스트 추출
  Future<_MlKitResult> _extractWithMlKit(Uint8List imageBytes) async {
    print('📷 OCR: Trying ML Kit (on-device)...');

    // Uint8List를 임시 파일로 저장 (ML Kit은 파일 경로 필요)
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageBytes);

    try {
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // 블록이 없으면 실패
      if (recognizedText.blocks.isEmpty) {
        print('📷 OCR: ML Kit found no text blocks');
        return _MlKitResult(text: '', confidence: 0.0, isValid: false);
      }

      // 평균 신뢰도 계산 (라인 단위)
      final confidences = recognizedText.blocks
          .expand((block) => block.lines)
          .where((line) => line.confidence != null)
          .map((line) => line.confidence!)
          .toList();

      final avgConfidence = confidences.isEmpty
          ? 0.0
          : confidences.fold(0.0, (sum, c) => sum + c) / confidences.length;

      print('📷 OCR: ML Kit extracted ${recognizedText.text.length} chars, '
          '${recognizedText.blocks.length} blocks, '
          'avg confidence: ${avgConfidence.toStringAsFixed(2)}');

      return _MlKitResult(
        text: recognizedText.text,
        confidence: avgConfidence,
        isValid: recognizedText.text.isNotEmpty && avgConfidence >= _minConfidence,
      );
    } finally {
      // 임시 파일 정리
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// Cloud Vision API로 텍스트 추출 (폴백)
  Future<String> _extractWithCloudVision(Uint8List imageBytes) async {
    print('📷 OCR: Using Cloud Vision API (fallback)...');

    final base64Image = base64Encode(imageBytes);
    print('📷 OCR: Image base64 length: ${base64Image.length}');

    final response = await supabase.functions.invoke(
      'ocr-image',
      body: {
        'imageBase64': base64Image,
      },
    );

    print('📷 OCR: Cloud Vision response status: ${response.status}');

    if (response.status >= 400) {
      final errorMsg = response.data?['error'] ?? response.data?['details'] ?? 'Unknown error';
      throw Exception('$errorMsg (${response.status})');
    }

    if (response.data == null) {
      throw Exception('OCR 처리에 실패했습니다');
    }

    final text = response.data['text'] as String? ?? '';
    print('📷 OCR: Cloud Vision extracted ${text.length} chars');
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

  /// 리소스 정리
  void dispose() {
    _textRecognizer.close();
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

/// ML Kit 결과를 담는 내부 클래스
class _MlKitResult {
  final String text;
  final double confidence;
  final bool isValid;

  _MlKitResult({
    required this.text,
    required this.confidence,
    required this.isValid,
  });
}
