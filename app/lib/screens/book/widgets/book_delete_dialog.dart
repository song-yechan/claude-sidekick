/// 책 삭제 확인 다이얼로그
///
/// 책 삭제 전 사용자에게 확인을 요청하는 다이얼로그입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../providers/book_provider.dart';

/// 책 삭제 확인 다이얼로그를 표시합니다.
void showBookDeleteDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String bookId,
  required String bookTitle,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        context.l10n.book_delete,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurface,
        ),
      ),
      content: Text(
        context.l10n.book_deleteConfirm(bookTitle),
        style: TextStyle(
          fontSize: 15,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(context.l10n.common_cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final success = await deleteBook(ref, bookId);
            if (success && context.mounted) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.book_deleted),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.small),
                  ),
                ),
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.error,
          ),
          child: Text(context.l10n.common_delete),
        ),
      ],
    ),
  );
}
