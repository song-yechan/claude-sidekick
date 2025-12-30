import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/book_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/book/book_search_card.dart';
import '../../widgets/category/category_chip.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _selectedCategoryIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(bookSearchProvider.notifier).search(query);
    }
  }

  Future<void> _addBook(BookSearchResult book) async {
    try {
      final result = await addBook(
        ref,
        title: book.title,
        author: book.author,
        isbn: book.isbn.isNotEmpty ? book.isbn : null,
        publisher: book.publisher.isNotEmpty ? book.publisher : null,
        publishDate: book.publishDate.isNotEmpty ? book.publishDate : null,
        coverImage: book.coverImage.isNotEmpty ? book.coverImage : null,
        description: book.description.isNotEmpty ? book.description : null,
        pageCount: book.pageCount,
        categoryIds: _selectedCategoryIds.toList(),
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${book.title}이(가) 추가되었습니다'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.small),
            ),
          ),
        );
        ref.read(bookSearchProvider.notifier).clear();
        _searchController.clear();
        _selectedCategoryIds.clear();
        setState(() {});
        // 추가된 책의 상세 페이지로 이동
        context.push('/books/${result.id}');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('책 추가에 실패했습니다'),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.small),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: context.colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.small),
            ),
          ),
        );
      }
    }
  }

  void _showAddDialog(BookSearchResult book) {
    final categoriesAsync = ref.read(categoriesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.extraLarge),
        ),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
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
              Text(
                '서재에 추가',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              // 책 정보
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppShapes.medium),
                ),
                child: Row(
                  children: [
                    if (book.coverImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppShapes.small),
                        child: Image.network(
                          book.coverImage,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: context.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppShapes.small),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: context.colors.outline,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: context.colors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: context.colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 카테고리 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '카테고리 선택 (선택사항)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    '${_selectedCategoryIds.length}/$maxCategoriesPerBook',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedCategoryIds.length >= maxCategoriesPerBook
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                      fontWeight: _selectedCategoryIds.length >= maxCategoriesPerBook
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Text(
                      '카테고리가 없습니다',
                      style: TextStyle(color: context.colors.onSurfaceVariant),
                    );
                  }
                  final isMaxReached = _selectedCategoryIds.length >= maxCategoriesPerBook;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected =
                          _selectedCategoryIds.contains(cat.id);
                      final isDisabled = !isSelected && isMaxReached;
                      return Opacity(
                        opacity: isDisabled ? 0.4 : 1.0,
                        child: CategoryChip(
                          category: cat,
                          isSelected: isSelected,
                          onTap: isDisabled
                              ? null
                              : () {
                                  setModalState(() {
                                    if (isSelected) {
                                      _selectedCategoryIds.remove(cat.id);
                                    } else {
                                      _selectedCategoryIds.add(cat.id);
                                    }
                                  });
                                  setState(() {});
                                },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => CircularProgressIndicator(
                  color: context.colors.primary,
                  strokeWidth: 2,
                ),
                error: (e, s) => Text(
                  '카테고리 로딩 실패',
                  style: TextStyle(color: context.colors.error),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // 추가 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(modalContext);
                    _addBook(book);
                  },
                  child: const Text(
                    '추가하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookSearchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                '책 검색',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '책 제목, 저자, ISBN으로 검색',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.colors.onSurfaceVariant,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: context.colors.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(bookSearchProvider.notifier).clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _search(),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 검색 결과
            Expanded(
              child: searchState.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : searchState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: context.colors.errorContainer,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  size: 32,
                                  color: context.colors.onErrorContainer,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                '검색에 실패했어요',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                searchState.error!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : searchState.results.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: context.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      size: 32,
                                      color: context.colors.outline,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    '책을 검색해보세요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '제목, 저자, ISBN으로 검색할 수 있어요',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: searchState.results.length,
                              itemBuilder: (context, index) {
                                final book = searchState.results[index];
                                return BookSearchCard(
                                  book: book,
                                  onAdd: () => _showAddDialog(book),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
