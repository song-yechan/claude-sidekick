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
          color: context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppShapes.large),
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
                        color: context.surfaceContainerHigh,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            // 책 정보
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.colors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
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

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: context.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 40,
          color: context.colors.outline,
        ),
      ),
    );
  }
}
