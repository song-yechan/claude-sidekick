/// OCR 처리 다이얼로그
///
/// OCR 처리 중 로딩, 에러, 성공 상태를 표시하는 다이얼로그입니다.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/error_utils.dart';
import '../../../providers/note_provider.dart';
import 'save_note_dialog.dart';

/// OCR 처리 다이얼로그를 표시합니다.
void showOcrProcessingDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String bookId,
  required Uint8List imageBytes,
}) {
  // OCR 처리 시작
  ref.read(ocrProvider.notifier).processImage(imageBytes);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _OcrProcessingDialogContent(
      bookId: bookId,
    ),
  );
}

class _OcrProcessingDialogContent extends ConsumerWidget {
  final String bookId;

  const _OcrProcessingDialogContent({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrState = ref.watch(ocrProvider);

    // 처리 중
    if (ocrState.isProcessing) {
      return _buildProcessingDialog(context);
    }

    // 에러 발생
    if (ocrState.error != null) {
      return _buildErrorDialog(context, ref, ocrState.error!);
    }

    // 성공 - 저장 다이얼로그 표시
    return SaveNoteDialog(
      bookId: bookId,
      extractedText: ocrState.extractedText ?? '',
      onSaved: () {
        Navigator.pop(context);
        ref.read(ocrProvider.notifier).clear();
      },
    );
  }

  Widget _buildProcessingDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.ocr_extracting,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.ocr_processing,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog(BuildContext context, WidgetRef ref, Object error) {
    return AlertDialog(
      title: Text(context.l10n.ocr_extractFailed),
      content: Text(getUserFriendlyErrorMessage(context, error)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ref.read(ocrProvider.notifier).clear();
          },
          child: Text(context.l10n.common_confirm),
        ),
      ],
    );
  }
}
