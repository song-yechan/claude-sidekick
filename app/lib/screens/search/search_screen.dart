import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/book_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/book/book_card.dart';
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
    final result = await addBook(
      ref,
      title: book.title,
      author: book.author,
      isbn: book.isbn,
      publisher: book.publisher,
      publishDate: book.publishDate,
      coverImage: book.coverImage,
      description: book.description,
      categoryIds: _selectedCategoryIds.toList(),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title}이(가) 추가되었습니다')),
      );
      // 검색 결과 초기화
      ref.read(bookSearchProvider.notifier).clear();
      _searchController.clear();
      _selectedCategoryIds.clear();
      setState(() {});
    }
  }

  void _showAddDialog(BookSearchResult book) {
    final categoriesAsync = ref.read(categoriesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서재에 추가',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // 책 정보
              Row(
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
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          book.author,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 카테고리 선택
              Text(
                '카테고리 선택 (선택사항)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => categories.isEmpty
                    ? Text(
                        '카테고리가 없습니다',
                        style: TextStyle(color: Colors.grey.shade500),
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
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('카테고리 로딩 실패'),
              ),
              const SizedBox(height: 24),
              // 추가 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addBook(book);
                  },
                  child: const Text('추가'),
                ),
              ),
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
      appBar: AppBar(
        title: const Text('책 검색'),
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '책 제목, 저자, ISBN으로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(bookSearchProvider.notifier).clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(),
              textInputAction: TextInputAction.search,
            ),
          ),

          // 검색 결과
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('검색 실패: ${searchState.error}'),
                          ],
                        ),
                      )
                    : searchState.results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '책을 검색해보세요',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}
