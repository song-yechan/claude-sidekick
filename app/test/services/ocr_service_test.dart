import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/services/ocr_service.dart';

void main() {
  group('OcrResult', () {
    test('OcrResult creates correctly with required fields', () {
      final result = OcrResult(
        originalText: '추출된 텍스트입니다.',
        summary: '요약된 텍스트입니다.',
      );

      expect(result.originalText, '추출된 텍스트입니다.');
      expect(result.summary, '요약된 텍스트입니다.');
    });

    test('OcrResult handles empty strings', () {
      final result = OcrResult(
        originalText: '',
        summary: '',
      );

      expect(result.originalText, '');
      expect(result.summary, '');
    });

    test('OcrResult handles long text', () {
      final longText = 'A' * 10000;
      final result = OcrResult(
        originalText: longText,
        summary: '요약',
      );

      expect(result.originalText.length, 10000);
    });

    test('OcrResult handles Korean text', () {
      final result = OcrResult(
        originalText: '한글 텍스트 테스트입니다. 특수문자도 포함: !@#\$%^&*()',
        summary: '한글 요약입니다.',
      );

      expect(result.originalText, contains('한글'));
      expect(result.summary, contains('한글'));
    });

    test('OcrResult handles multiline text', () {
      final multilineText = '''첫 번째 줄
두 번째 줄
세 번째 줄''';

      final result = OcrResult(
        originalText: multilineText,
        summary: '여러 줄 요약',
      );

      expect(result.originalText, contains('\n'));
      expect(result.originalText.split('\n').length, 3);
    });
  });
}
