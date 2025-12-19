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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TossColors.white,
          borderRadius: BorderRadius.circular(16),
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
                          color: TossColors.blueLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'p.${note.pageNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TossColors.blue,
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
                              ? TossColors.orangeLight
                              : TossColors.gray100,
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
                                  ? TossColors.orange
                                  : TossColors.gray600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              showSummary ? 'AI 요약' : '원문',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: showSummary
                                    ? TossColors.orange
                                    : TossColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Text(
                  dateFormat.format(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: TossColors.gray500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 내용
            Text(
              displayText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: TossColors.gray800,
              ),
            ),

            // 메모
            if (note.memo != null && note.memo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TossColors.gray50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: TossColors.gray500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.memo!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: TossColors.gray600,
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
              const SizedBox(height: 12),
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
                          color: TossColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: TossColors.gray600,
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
