import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                '내 서재',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 콘텐츠
            Expanded(
              child: booksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: context.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 40,
                              color: context.colors.outline,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            '아직 등록된 책이 없어요',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '검색 탭에서 책을 추가해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/search'),
                              icon: const Icon(Icons.search_rounded, size: 20),
                              label: const Text('책 검색하기'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onTap: () => context.push('/books/${book.id}'),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (error, _) => Center(
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
                        '불러오기에 실패했어요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$error',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(booksProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
