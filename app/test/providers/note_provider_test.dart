import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/note_provider.dart';

void main() {
  group('OcrState', () {
    test('기본 생성자는 모든 값이 null/false', () {
      const state = OcrState();

      expect(state.isProcessing, isFalse);
      expect(state.extractedText, isNull);
      expect(state.error, isNull);
    });

    test('copyWith으로 isProcessing 변경', () {
      const state = OcrState();
      final newState = state.copyWith(isProcessing: true);

      expect(newState.isProcessing, isTrue);
      expect(newState.extractedText, isNull);
      expect(newState.error, isNull);
    });

    test('copyWith으로 extractedText 설정', () {
      const state = OcrState(isProcessing: true);
      final newState = state.copyWith(
        isProcessing: false,
        extractedText: '추출된 텍스트',
      );

      expect(newState.isProcessing, isFalse);
      expect(newState.extractedText, '추출된 텍스트');
      expect(newState.error, isNull);
    });

    test('copyWith으로 error 설정', () {
      const state = OcrState(isProcessing: true);
      final newState = state.copyWith(
        isProcessing: false,
        error: '에러 발생',
      );

      expect(newState.isProcessing, isFalse);
      expect(newState.extractedText, isNull);
      expect(newState.error, '에러 발생');
    });

    test('error가 설정되면 이전 extractedText는 유지', () {
      const state = OcrState(extractedText: '기존 텍스트');
      final newState = state.copyWith(error: '새 에러');

      expect(newState.extractedText, '기존 텍스트');
      expect(newState.error, '새 에러');
    });
  });
}
