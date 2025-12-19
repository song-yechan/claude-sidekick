import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  bool _showSummary = true;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await picker.pickImage(source: source);
    if (image == null) return;

    // 이미지를 바이트로 읽기 (웹 호환성)
    final imageBytes = await image.readAsBytes();

    // OCR 처리 시작
    if (mounted) {
      _showOcrDialog(imageBytes);
    }
  }

  void _showOcrDialog(Uint8List imageBytes) {
    // OCR 처리 시작
    ref.read(ocrProvider.notifier).processImage(imageBytes);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final ocrState = ref.watch(ocrProvider);

          if (ocrState.isProcessing) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('텍스트를 추출하고 있습니다...'),
                ],
              ),
            );
          }

          if (ocrState.error != null) {
            return AlertDialog(
              title: const Text('오류'),
              content: Text(ocrState.error!),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
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
            summary: ocrState.summary,
            onSaved: () {
              Navigator.pop(context);
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
      builder: (context) => AlertDialog(
        title: const Text('책 삭제'),
        content: Text('${book.title}을(를) 삭제하시겠습니까?\n모든 노트도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await deleteBook(ref, widget.bookId);
              if (success && mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('책이 삭제되었습니다')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 앱바 with 책 표지
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
            ),
          ),

          // 책 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  if (book.publisher != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.publisher!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // 노트 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수집한 문장',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      // 요약/원문 토글
                      Row(
                        children: [
                          const Text('AI 요약'),
                          Switch(
                            value: _showSummary,
                            onChanged: (value) {
                              setState(() {
                                _showSummary = value;
                              });
                            },
                          ),
                        ],
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
                        Icon(
                          Icons.note_add,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 수집한 문장이 없습니다',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '카메라 버튼을 눌러 문장을 수집해보세요',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCard(
                          note: note,
                          showSummary: _showSummary,
                          onTap: () => context.push('/notes/${note.id}'),
                        ),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              child: Center(child: Text('오류: $error')),
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
  final String? summary;
  final VoidCallback onSaved;

  const _SaveNoteDialog({
    required this.bookId,
    required this.extractedText,
    this.summary,
    required this.onSaved,
  });

  @override
  ConsumerState<_SaveNoteDialog> createState() => _SaveNoteDialogState();
}

class _SaveNoteDialogState extends ConsumerState<_SaveNoteDialog> {
  late TextEditingController _contentController;
  final _pageController = TextEditingController();
  final _memoController = TextEditingController();
  bool _showSummary = true;
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
      summary: widget.summary,
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
            // 요약/원문 토글
            if (widget.summary != null)
              Row(
                children: [
                  const Text('AI 요약 보기'),
                  Switch(
                    value: _showSummary,
                    onChanged: (value) => setState(() => _showSummary = value),
                  ),
                ],
              ),

            // 추출된 텍스트 / 요약
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _showSummary && widget.summary != null
                            ? Icons.auto_awesome
                            : Icons.format_quote,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showSummary && widget.summary != null ? 'AI 요약' : '원문',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showSummary && widget.summary != null
                        ? widget.summary!
                        : widget.extractedText,
                    style: const TextStyle(height: 1.5),
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
