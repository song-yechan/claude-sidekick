import 'dart:convert';
import 'dart:io';
import '../core/supabase.dart';

class OcrService {
  /// 이미지에서 텍스트 추출 (OCR)
  Future<String> extractText(File imageFile) async {
    // 이미지를 base64로 인코딩
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await supabase.functions.invoke(
      'ocr-image',
      body: {
        'image': base64Image,
      },
    );

    if (response.data == null) {
      throw Exception('OCR 처리에 실패했습니다');
    }

    return response.data['text'] as String? ?? '';
  }

  /// 텍스트 요약
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

  /// 이미지에서 텍스트 추출 후 요약까지 수행
  Future<OcrResult> processImage(File imageFile) async {
    final extractedText = await extractText(imageFile);

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

class OcrResult {
  final String originalText;
  final String summary;

  OcrResult({
    required this.originalText,
    required this.summary,
  });
}
