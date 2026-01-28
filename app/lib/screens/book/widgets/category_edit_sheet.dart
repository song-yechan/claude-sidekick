/// 카테고리 편집 바텀시트
///
/// 책에 연결된 카테고리를 편집하는 바텀시트입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../widgets/category/category_chip.dart';

/// 카테고리 편집 바텀시트를 표시합니다.
void showCategoryEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String bookId,
  required List<String> initialCategoryIds,
}) {
  final selectedIds = Set<String>.from(initialCategoryIds);

  showModalBottomSheet(
    context: context,
    backgroundColor: context.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppShapes.extraLarge),
      ),
    ),
    builder: (sheetContext) => _CategoryEditSheetContent(
      ref: ref,
      bookId: bookId,
      initialSelectedIds: selectedIds,
    ),
  );
}

class _CategoryEditSheetContent extends StatefulWidget {
  final WidgetRef ref;
  final String bookId;
  final Set<String> initialSelectedIds;

  const _CategoryEditSheetContent({
    required this.ref,
    required this.bookId,
    required this.initialSelectedIds,
  });

  @override
  State<_CategoryEditSheetContent> createState() =>
      _CategoryEditSheetContentState();
}

class _CategoryEditSheetContentState extends State<_CategoryEditSheetContent> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = widget.ref.watch(categoriesProvider);
    final isMaxReached = _selectedIds.length >= maxCategoriesPerBook;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들 바
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.category_edit,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                Text(
                  '${_selectedIds.length}/$maxCategoriesPerBook',
                  style: TextStyle(
                    fontSize: 14,
                    color: isMaxReached
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                    fontWeight: isMaxReached ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 카테고리 목록
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        context.l10n.category_noListHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = _selectedIds.contains(cat.id);
                    final isDisabled = !isSelected && isMaxReached;
                    return Opacity(
                      opacity: isDisabled ? 0.4 : 1.0,
                      child: CategoryChip(
                        category: cat,
                        isSelected: isSelected,
                        onTap: isDisabled
                            ? null
                            : () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIds.remove(cat.id);
                                  } else {
                                    _selectedIds.add(cat.id);
                                  }
                                });
                              },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Text(context.l10n.category_loadError),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () => _save(context),
                child: Text(context.l10n.common_save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.category_updated;
    Navigator.pop(context);
    final success = await updateBookCategories(
      widget.ref,
      widget.bookId,
      _selectedIds.toList(),
    );
    if (success && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.small),
          ),
        ),
      );
    }
  }
}
