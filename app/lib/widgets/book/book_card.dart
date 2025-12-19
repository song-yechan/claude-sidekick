import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TossColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 표지
            Expanded(
              child: book.coverImage != null && book.coverImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: TossColors.gray100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TossColors.blue,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            // 책 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: TossColors.gray900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TossColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: TossColors.gray100,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: TossColors.gray400,
        ),
      ),
    );
  }
}
