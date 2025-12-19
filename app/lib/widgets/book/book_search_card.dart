import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/book.dart';

/// 토스 스타일 검색 결과 책 카드 위젯
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 표지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.coverImage.isNotEmpty
                ? Image.network(
                    book.coverImage,
                    width: 56,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          const SizedBox(width: 16),
          // 책 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TossColors.gray900,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TossColors.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.publisher.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.publisher,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TossColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 추가 버튼
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TossColors.blueLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 22,
                color: TossColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: TossColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 28,
        color: TossColors.gray400,
      ),
    );
  }
}
