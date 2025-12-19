import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/book.dart';

/// 검색 결과 책 카드 위젯
class BookSearchCard extends StatelessWidget {
  final BookSearchResult book;
  final VoidCallback? onAdd;

  const BookSearchCard({
    super.key,
    required this.book,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.large),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지
          ClipRRect(
            borderRadius: BorderRadius.circular(AppShapes.small),
            child: book.coverImage.isNotEmpty
                ? Image.network(
                    book.coverImage,
                    width: 56,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
          const SizedBox(width: AppSpacing.lg),
          // 책 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.publisher.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.publisher,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 추가 버튼
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 22,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: context.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppShapes.small),
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: 28,
        color: context.colors.outline,
      ),
    );
  }
}
