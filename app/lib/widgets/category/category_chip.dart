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
              : TossColors.gray100,
          borderRadius: BorderRadius.circular(20),
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
                color: isSelected ? category.colorValue : TossColors.gray700,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TossColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 색상 표시
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.colorValue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: category.colorValue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 카테고리 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: TossColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$bookCount권',
                    style: const TextStyle(
                      color: TossColors.gray500,
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
                    color: TossColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: TossColors.gray500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: TossColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
