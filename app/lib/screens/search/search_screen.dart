import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
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
        categoryIds: _selectedCategoryIds.toList(),
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${book.title}이(가) 추가되었습니다'),
            backgroundColor: TossColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        ref.read(bookSearchProvider.notifier).clear();
        _searchController.clear();
        _selectedCategoryIds.clear();
        setState(() {});
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('책 추가에 실패했습니다'),
            backgroundColor: TossColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: TossColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      backgroundColor: TossColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    color: TossColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '서재에 추가',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TossColors.gray900,
                ),
              ),
              const SizedBox(height: 20),
              // 책 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TossColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (book.coverImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                          color: TossColors.gray200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: TossColors.gray400,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: TossColors.gray900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            style: const TextStyle(
                              color: TossColors.gray600,
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
              const Text(
                '카테고리 선택 (선택사항)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TossColors.gray700,
                ),
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) => categories.isEmpty
                    ? const Text(
                        '카테고리가 없습니다',
                        style: TextStyle(color: TossColors.gray500),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSelected =
                              _selectedCategoryIds.contains(cat.id);
                          return CategoryChip(
                            category: cat,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedCategoryIds.remove(cat.id);
                                } else {
                                  _selectedCategoryIds.add(cat.id);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                loading: () => const CircularProgressIndicator(
                  color: TossColors.blue,
                  strokeWidth: 2,
                ),
                error: (_, __) => const Text(
                  '카테고리 로딩 실패',
                  style: TextStyle(color: TossColors.red),
                ),
              ),
              const SizedBox(height: 24),
              // 추가 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
              const SizedBox(height: 8),
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
              child: const Text(
                '책 검색',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: TossColors.gray900,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 검색바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 16,
                  color: TossColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: '책 제목, 저자, ISBN으로 검색',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: TossColors.gray500,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: TossColors.gray500,
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
            const SizedBox(height: 16),

            // 검색 결과
            Expanded(
              child: searchState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TossColors.blue,
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
                                  color: TossColors.redLight,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  size: 32,
                                  color: TossColors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '검색에 실패했어요',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: TossColors.gray700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                searchState.error!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: TossColors.gray500,
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
                                      color: TossColors.gray100,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: const Icon(
                                      Icons.search_rounded,
                                      size: 32,
                                      color: TossColors.gray400,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '책을 검색해보세요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: TossColors.gray700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '제목, 저자, ISBN으로 검색할 수 있어요',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: TossColors.gray500,
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
