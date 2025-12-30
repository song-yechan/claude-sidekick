/// OcrNotifier 테스트
///
/// FakeOcrService를 사용하여 OcrNotifier의 동작을 검증합니다.
/// 실제 API 호출 없이 OCR 로직을 테스트합니다.
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/note_provider.dart';
import '../mocks/fake_ocr_service.dart';

void main() {
  late FakeOcrService fakeOcrService;
  late OcrNotifier notifier;

  setUp(() {
    fakeOcrService = FakeOcrService();
    notifier = OcrNotifier(fakeOcrService);
  });

  tearDown(() {
    fakeOcrService.reset();
  });

  group('초기 상태', () {
    test('초기 상태는 모든 값이 null/false', () {
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.extractedText, isNull);
      expect(notifier.state.error, isNull);
    });
  });

  group('processImage', () {
    test('이미지 처리 성공 시 텍스트가 추출된다', () async {
      // Given
      fakeOcrService.extractedText = '추출된 텍스트입니다.';
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.extractedText, '추출된 텍스트입니다.');
      expect(notifier.state.error, isNull);
    });

    test('이미지 처리 시 OcrService.processImage가 호출된다', () async {
      // Given
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(fakeOcrService.processImageCallCount, 1);
      expect(fakeOcrService.lastImageBytes, imageBytes);
    });

    test('이미지 처리 실패 시 에러가 설정된다', () async {
      // Given
      fakeOcrService.processImageError = Exception('OCR 처리 실패');
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.extractedText, isNull);
      expect(notifier.state.error, contains('OCR 처리 실패'));
    });

    test('빈 텍스트 추출도 정상 처리된다', () async {
      // Given
      fakeOcrService.extractedText = '';
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.extractedText, '');
      expect(notifier.state.error, isNull);
    });

    test('여러 번 처리 시 마지막 결과만 유지된다', () async {
      // Given
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // When - 첫 번째 처리
      fakeOcrService.extractedText = '첫 번째 텍스트';
      await notifier.processImage(imageBytes);
      expect(notifier.state.extractedText, '첫 번째 텍스트');

      // When - 두 번째 처리
      fakeOcrService.extractedText = '두 번째 텍스트';
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.extractedText, '두 번째 텍스트');
      expect(fakeOcrService.processImageCallCount, 2);
    });

    test('한글 텍스트가 정상적으로 추출된다', () async {
      // Given
      fakeOcrService.extractedText = '책 속의 인상 깊은 문장입니다. 가나다라마바사';
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.extractedText, contains('인상 깊은 문장'));
      expect(notifier.state.extractedText, contains('가나다라마바사'));
    });

    test('긴 텍스트도 정상적으로 추출된다', () async {
      // Given
      final longText = 'Lorem ipsum dolor sit amet, ' * 100;
      fakeOcrService.extractedText = longText;
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // When
      await notifier.processImage(imageBytes);

      // Then
      expect(notifier.state.extractedText, longText);
      expect(notifier.state.extractedText!.length, greaterThan(1000));
    });
  });

  group('clear', () {
    test('clear 호출 시 상태가 초기화된다', () async {
      // Given
      fakeOcrService.extractedText = '추출된 텍스트';
      await notifier.processImage(Uint8List.fromList([1, 2, 3]));
      expect(notifier.state.extractedText, isNotNull);

      // When
      notifier.clear();

      // Then
      expect(notifier.state.isProcessing, false);
      expect(notifier.state.extractedText, isNull);
      expect(notifier.state.error, isNull);
    });

    test('에러 상태도 clear로 초기화된다', () async {
      // Given
      fakeOcrService.processImageError = Exception('에러');
      await notifier.processImage(Uint8List.fromList([1, 2, 3]));
      expect(notifier.state.error, isNotNull);

      // When
      notifier.clear();

      // Then
      expect(notifier.state.error, isNull);
    });
  });

  group('FakeOcrService', () {
    test('extractText 호출 횟수를 추적한다', () async {
      // When
      await fakeOcrService.extractText(Uint8List.fromList([1]));
      await fakeOcrService.extractText(Uint8List.fromList([2]));
      await fakeOcrService.extractText(Uint8List.fromList([3]));

      // Then
      expect(fakeOcrService.extractTextCallCount, 3);
    });

    test('processImage 호출 횟수를 추적한다', () async {
      // When
      await fakeOcrService.processImage(Uint8List.fromList([1]));
      await fakeOcrService.processImage(Uint8List.fromList([2]));

      // Then
      expect(fakeOcrService.processImageCallCount, 2);
    });

    test('reset 후 상태가 초기화된다', () async {
      // Given
      fakeOcrService.extractedText = '텍스트';
      await fakeOcrService.processImage(Uint8List.fromList([1, 2, 3]));

      // When
      fakeOcrService.reset();

      // Then
      expect(fakeOcrService.extractedText, '');
      expect(fakeOcrService.processImageCallCount, 0);
      expect(fakeOcrService.extractTextCallCount, 0);
      expect(fakeOcrService.lastImageBytes, isNull);
    });

    test('extractText 에러 시뮬레이션', () async {
      // Given
      fakeOcrService.extractTextError = Exception('API 오류');

      // When & Then
      expect(
        () => fakeOcrService.extractText(Uint8List.fromList([1])),
        throwsA(isA<Exception>()),
      );
    });

    test('processImage 에러 시뮬레이션', () async {
      // Given
      fakeOcrService.processImageError = Exception('처리 실패');

      // When & Then
      expect(
        () => fakeOcrService.processImage(Uint8List.fromList([1])),
        throwsA(isA<Exception>()),
      );
    });
  });
}
