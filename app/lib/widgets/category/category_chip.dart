import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.colorValue.withValues(alpha: 0.15)
              : context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.full),
          border: Border.all(
            color: isSelected ? category.colorValue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: category.colorValue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? category.colorValue
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final int bookCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.bookCount = 0,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppShapes.large),
        ),
        child: Row(
          children: [
            // 색상 표시
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.colorValue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppShapes.medium),
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: category.colorValue,
                    borderRadius: BorderRadius.circular(AppShapes.extraSmall),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // 카테고리 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$bookCount권',
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // 삭제 버튼
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppShapes.small),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
