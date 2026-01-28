/// 책 상세 화면
///
/// 책 정보와 수집된 노트 목록을 표시합니다.
/// OCR을 통해 새 노트를 추가할 수 있습니다.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;

import '../common/perspective_crop_screen.dart';
import '../../core/theme.dart';
import '../../core/error_utils.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/note/note_card.dart';
import '../../widgets/category/category_chip.dart';
import 'widgets/image_source_sheet.dart';
import 'widgets/ocr_processing_dialog.dart';
import 'widgets/category_edit_sheet.dart';
import 'widgets/book_delete_dialog.dart';

/// 책 상세 화면
class BookDetailScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  /// 이미지를 선택하고 OCR 처리를 시작합니다.
  Future<void> _pickImage() async {
    final source = await showImageSourceSheet(context);
    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    // 이미지 크롭 화면 표시
    final croppedFile = await _cropImage(image.path);
    if (croppedFile == null) return;

    // 크롭된 이미지를 바이트로 읽기
    final croppedBytes = await croppedFile.readAsBytes();

    // 이미지 리사이즈 (OCR 최적화)
    final resizedBytes = await _resizeImageForOcr(croppedBytes);

    // OCR 처리 시작
    if (mounted) {
      showOcrProcessingDialog(
        context: context,
        ref: ref,
        bookId: widget.bookId,
        imageBytes: resizedBytes,
      );
    }
  }

  /// 이미지 크롭 화면을 표시합니다.
  Future<File?> _cropImage(String imagePath) async {
    return Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => PerspectiveCropScreen(imagePath: imagePath),
      ),
    );
  }

  /// 이미지 리사이즈 (OCR 최적화)
  Future<Uint8List> _resizeImageForOcr(Uint8List bytes) async {
    const maxDimension = 1920;
    const jpegQuality = 85;

    try {
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return bytes;

      final width = originalImage.width;
      final height = originalImage.height;

      if (width <= maxDimension && height <= maxDimension) {
        final compressed = img.encodeJpg(originalImage, quality: jpegQuality);
        return Uint8List.fromList(compressed);
      }

      img.Image resized;
      if (width > height) {
        resized = img.copyResize(originalImage, width: maxDimension);
      } else {
        resized = img.copyResize(originalImage, height: maxDimension);
      }

      final encoded = img.encodeJpg(resized, quality: jpegQuality);
      return Uint8List.fromList(encoded);
    } catch (e) {
      return bytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookProvider(widget.bookId));
    final notesAsync = ref.watch(notesByBookProvider(widget.bookId));

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.book_notFound)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _BookDetailAppBar(
            book: book,
            onDelete: () => showBookDeleteDialog(
              context: context,
              ref: ref,
              bookId: widget.bookId,
              bookTitle: book.title,
            ),
          ),
          _BookInfoSection(
            book: book,
            onEditCategories: () => showCategoryEditSheet(
              context: context,
              ref: ref,
              bookId: widget.bookId,
              initialCategoryIds: book.categoryIds,
            ),
          ),
          _NotesSection(notesAsync: notesAsync),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt),
        label: Text(context.l10n.note_collect),
      ),
    );
  }
}

/// 책 상세 앱바
class _BookDetailAppBar extends StatelessWidget {
  final Book book;
  final VoidCallback onDelete;

  const _BookDetailAppBar({
    required this.book,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: surfaceColor,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: context.colors.onSurface,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: context.colors.onSurface,
            ),
          ),
          onPressed: onDelete,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: book.coverImage != null
            ? CachedNetworkImage(
                imageUrl: book.coverImage!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.3),
                colorBlendMode: BlendMode.darken,
              )
            : Container(color: context.colors.primaryContainer),
      ),
    );
  }
}

/// 책 정보 섹션
class _BookInfoSection extends ConsumerWidget {
  final Book book;
  final VoidCallback onEditCategories;

  const _BookInfoSection({
    required this.book,
    required this.onEditCategories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              book.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 저자
            Text(
              book.author,
              style: TextStyle(
                fontSize: 16,
                color: context.colors.onSurfaceVariant,
              ),
            ),

            // 출판사
            if (book.publisher != null) ...[
              const SizedBox(height: 4),
              Text(
                book.publisher!,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.outline,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // 카테고리 섹션
            _CategorySection(
              book: book,
              onEdit: onEditCategories,
            ),

            const SizedBox(height: AppSpacing.lg),
            Divider(color: context.colors.outlineVariant),
            const SizedBox(height: AppSpacing.lg),

            // 노트 헤더
            Text(
              context.l10n.library_collectedNotes,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 섹션
class _CategorySection extends ConsumerWidget {
  final Book book;
  final VoidCallback onEdit;

  const _CategorySection({
    required this.book,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Row(
      children: [
        Expanded(
          child: categoriesAsync.when(
            data: (allCategories) {
              final bookCategories = allCategories
                  .where((c) => book.categoryIds.contains(c.id))
                  .toList();

              if (bookCategories.isEmpty) {
                return GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppShapes.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.category_title,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bookCategories
                    .map((cat) => CategoryChip(category: cat))
                    .toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ),
        // 카테고리가 있을 때만 수정 버튼 표시
        if (book.categoryIds.isNotEmpty)
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
            tooltip: context.l10n.category_edit,
          ),
      ],
    );
  }
}

/// 노트 목록 섹션
class _NotesSection extends StatelessWidget {
  final AsyncValue<List<dynamic>> notesAsync;

  const _NotesSection({required this.notesAsync});

  @override
  Widget build(BuildContext context) {
    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = notes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NoteCard(
                    note: note,
                    showSummary: false,
                    onTap: () => context.push('/notes/${note.id}'),
                  ),
                );
              },
              childCount: notes.length,
            ),
          ),
        );
      },
      loading: () => SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: context.colors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        child: Center(
          child: Text(
            getUserFriendlyErrorMessage(context, error),
            style: TextStyle(color: context.colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              Icons.format_quote_rounded,
              size: 40,
              color: context.colors.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.home_noNotes,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.note_collectHint,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
