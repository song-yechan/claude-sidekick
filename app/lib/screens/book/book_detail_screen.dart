import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;
import '../../core/theme.dart';
import '../../core/error_utils.dart';
import '../../providers/book_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/note/note_card.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppShapes.extraLarge),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppShapes.medium),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              title: Text(
                '카메라',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppShapes.medium),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: context.colors.onSecondaryContainer,
                ),
              ),
              title: Text(
                '갤러리',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.colors.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    // iOS에서 HEIC 형식을 JPEG으로 자동 변환하도록 설정
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
      _showOcrDialog(resizedBytes);
    }
  }

  /// 이미지 크롭 화면을 표시합니다.
  Future<File?> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '이미지 자르기',
          toolbarColor: context.colors.surface,
          toolbarWidgetColor: context.colors.onSurface,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: context.colors.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: '이미지 자르기',
          cancelButtonTitle: '취소',
          doneButtonTitle: '완료',
          resetButtonHidden: false,
          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// 이미지 리사이즈 (OCR 최적화)
  /// 최대 1920px 너비/높이, JPEG 85% 품질로 압축
  Future<Uint8List> _resizeImageForOcr(Uint8List bytes) async {
    const maxDimension = 1920;
    const jpegQuality = 85;

    try {
      // 이미지 디코딩
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return bytes;

      // 리사이즈가 필요한지 확인
      final width = originalImage.width;
      final height = originalImage.height;

      if (width <= maxDimension && height <= maxDimension) {
        // 이미 충분히 작은 경우 JPEG으로 압축만 수행
        final compressed = img.encodeJpg(originalImage, quality: jpegQuality);
        return Uint8List.fromList(compressed);
      }

      // 비율 유지하며 리사이즈
      img.Image resized;
      if (width > height) {
        resized = img.copyResize(originalImage, width: maxDimension);
      } else {
        resized = img.copyResize(originalImage, height: maxDimension);
      }

      // JPEG으로 인코딩
      final encoded = img.encodeJpg(resized, quality: jpegQuality);
      return Uint8List.fromList(encoded);
    } catch (e) {
      // 리사이즈 실패 시 원본 반환
      return bytes;
    }
  }

  void _showOcrDialog(Uint8List imageBytes) {
    // OCR 처리 시작
    ref.read(ocrProvider.notifier).processImage(imageBytes);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (dialogContext, ref, _) {
          final ocrState = ref.watch(ocrProvider);

          if (ocrState.isProcessing) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(dialogContext).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '텍스트 추출 중',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(dialogContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이미지에서 텍스트를 인식하고 있습니다.\n잠시만 기다려주세요...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (ocrState.error != null) {
            return AlertDialog(
              title: const Text('텍스트 추출 실패'),
              content: Text(getUserFriendlyErrorMessage(ocrState.error!)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ref.read(ocrProvider.notifier).clear();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          }

          // OCR 성공 - 저장 다이얼로그 표시
          return _SaveNoteDialog(
            bookId: widget.bookId,
            extractedText: ocrState.extractedText ?? '',
            onSaved: () {
              Navigator.pop(dialogContext);
              ref.read(ocrProvider.notifier).clear();
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog() {
    final book = ref.read(bookProvider(widget.bookId));
    if (book == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '책 삭제',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        content: Text(
          '${book.title}을(를) 삭제하시겠습니까?\n모든 노트도 함께 삭제됩니다.',
          style: TextStyle(
            fontSize: 15,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await deleteBook(ref, widget.bookId);
              if (success && mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('책이 삭제되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppShapes.small),
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookProvider(widget.bookId));
    final notesAsync = ref.watch(notesByBookProvider(widget.bookId));

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('책을 찾을 수 없습니다')),
      );
    }

    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 앱바 with 책 표지
          SliverAppBar(
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
                onPressed: _showDeleteDialog,
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
                  : Container(
                      color: context.colors.primaryContainer,
                    ),
            ),
          ),

          // 책 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
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
                  Divider(color: context.colors.outlineVariant),
                  const SizedBox(height: AppSpacing.lg),

                  // 노트 헤더
                  Row(
                    children: [
                      Text(
                        '수집한 문장',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 노트 목록
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                          '아직 수집한 문장이 없어요',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '카메라 버튼을 눌러 문장을 수집해보세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          showSummary: false, // 항상 원문 표시
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
                  getUserFriendlyErrorMessage(error),
                  style: TextStyle(color: context.colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt),
        label: const Text('문장 수집'),
      ),
    );
  }
}

/// 노트 저장 다이얼로그
class _SaveNoteDialog extends ConsumerStatefulWidget {
  final String bookId;
  final String extractedText;
  final VoidCallback onSaved;

  const _SaveNoteDialog({
    required this.bookId,
    required this.extractedText,
    required this.onSaved,
  });

  @override
  ConsumerState<_SaveNoteDialog> createState() => _SaveNoteDialogState();
}

class _SaveNoteDialogState extends ConsumerState<_SaveNoteDialog> {
  late TextEditingController _contentController;
  final _pageController = TextEditingController();
  final _memoController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final note = await addNote(
      ref,
      bookId: widget.bookId,
      content: _contentController.text,
      pageNumber:
          _pageController.text.isNotEmpty ? int.tryParse(_pageController.text) : null,
      memo: _memoController.text.isNotEmpty ? _memoController.text : null,
    );

    setState(() => _isSaving = false);

    if (note != null) {
      widget.onSaved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('노트가 저장되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('문장 저장'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 추출된 텍스트
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppShapes.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '추출된 텍스트',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.extractedText,
                    style: TextStyle(
                      height: 1.6,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 페이지 번호
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '페이지 번호 (선택)',
                prefixIcon: Icon(Icons.bookmark_outline),
              ),
            ),
            const SizedBox(height: 12),

            // 메모
            TextField(
              controller: _memoController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '메모 (선택)',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
      ],
    );
  }
}
