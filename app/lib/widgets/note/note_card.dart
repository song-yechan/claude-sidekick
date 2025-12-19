import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool showSummary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.showSummary = true,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayText =
        showSummary && note.summary != null ? note.summary! : note.content;
    final dateFormat = DateFormat('yyyy.MM.dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppShapes.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 페이지 번호 + 날짜
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (note.pageNumber != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'p.${note.pageNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (note.summary != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: showSummary
                              ? context.colors.tertiaryContainer
                              : context.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              showSummary
                                  ? Icons.auto_awesome
                                  : Icons.format_quote_rounded,
                              size: 12,
                              color: showSummary
                                  ? context.colors.onTertiaryContainer
                                  : context.colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              showSummary ? 'AI 요약' : '원문',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: showSummary
                                    ? context.colors.onTertiaryContainer
                                    : context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Text(
                  dateFormat.format(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 내용
            Text(
              displayText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: context.colors.onSurface,
              ),
            ),

            // 메모
            if (note.memo != null && note.memo!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.memo!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 태그
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: note.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppShapes.medium),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
