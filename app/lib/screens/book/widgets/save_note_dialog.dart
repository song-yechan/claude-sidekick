/// 노트 저장 다이얼로그
///
/// OCR로 추출된 텍스트를 편집하고 노트로 저장하는 다이얼로그입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../providers/note_provider.dart';

/// 노트 저장 다이얼로그
class SaveNoteDialog extends ConsumerStatefulWidget {
  /// 책 ID
  final String bookId;

  /// OCR로 추출된 텍스트
  final String extractedText;

  /// 저장 완료 콜백
  final VoidCallback onSaved;

  const SaveNoteDialog({
    super.key,
    required this.bookId,
    required this.extractedText,
    required this.onSaved,
  });

  @override
  ConsumerState<SaveNoteDialog> createState() => _SaveNoteDialogState();
}

class _SaveNoteDialogState extends ConsumerState<SaveNoteDialog> {
  late TextEditingController _contentController;
  final _pageController = TextEditingController();
  final _memoController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final note = await addNote(
      ref,
      bookId: widget.bookId,
      content: _contentController.text,
      pageNumber: _pageController.text.isNotEmpty
          ? int.tryParse(_pageController.text)
          : null,
      memo: _memoController.text.isNotEmpty ? _memoController.text : null,
    );

    setState(() => _isSaving = false);

    if (note != null) {
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.note_saved)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.note_saveSentence),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 추출된 텍스트 (수정 가능)
            _buildExtractedTextSection(context),
            const SizedBox(height: 16),

            // 페이지 번호
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.note_pageNumber,
                prefixIcon: const Icon(Icons.bookmark_outline),
              ),
            ),
            const SizedBox(height: 12),

            // 메모
            TextField(
              controller: _memoController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.l10n.note_memoOptional,
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
      ),
      actionsOverflowButtonSpacing: 0,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: Text(context.l10n.common_cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.common_save),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExtractedTextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_quote_rounded,
              size: 16,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.ocr_extractedText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              context.l10n.ocr_canEdit,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _contentController,
          maxLines: null,
          minLines: 3,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: context.colors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.surfaceContainerLow,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppShapes.medium),
              borderSide: BorderSide.none,
            ),
            hintText: context.l10n.ocr_editExtracted,
          ),
        ),
      ],
    );
  }
}
