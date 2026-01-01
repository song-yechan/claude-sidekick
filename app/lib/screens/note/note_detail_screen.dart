import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/note_provider.dart';
import '../../providers/book_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _showSummary = true;
  bool _isEditingMemo = false;
  bool _isEditingContent = false;
  late TextEditingController _memoController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '노트 삭제',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
        content: Text(
          '이 노트를 삭제하시겠습니까?',
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
              // 삭제 전에 bookId 저장 (삭제 후 note가 null이 되므로)
              final note = ref.read(noteProvider(widget.noteId));
              final bookId = note?.bookId;
              final success = await deleteNote(ref, widget.noteId, bookId: bookId);
              if (success && mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('노트가 삭제되었습니다'),
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

  Future<void> _saveMemo() async {
    final success = await updateNote(
      ref,
      widget.noteId,
      memo: _memoController.text,
    );

    if (success && mounted) {
      setState(() => _isEditingMemo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메모가 저장되었습니다')),
      );
    }
  }

  Future<void> _saveContent() async {
    final success = await updateNote(
      ref,
      widget.noteId,
      content: _contentController.text,
    );

    if (success && mounted) {
      setState(() => _isEditingContent = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본문이 저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = ref.watch(noteProvider(widget.noteId));
    final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');

    if (note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            '노트를 찾을 수 없습니다',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ),
      );
    }

    // 컨트롤러 초기화
    if (!_isEditingMemo && _memoController.text != (note.memo ?? '')) {
      _memoController.text = note.memo ?? '';
    }
    if (!_isEditingContent && _contentController.text != note.content) {
      _contentController.text = note.content;
    }

    final book = ref.watch(bookProvider(note.bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('노트'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 정보
            if (book != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppShapes.large),
                ),
                child: Row(
                  children: [
                    book.coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppShapes.small),
                            child: Image.network(
                              book.coverImage!,
                              width: 44,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 44,
                            height: 60,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: context.colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.author,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (note.pageNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppShapes.small),
                        ),
                        child: Text(
                          'p.${note.pageNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // 날짜
            Text(
              dateFormat.format(note.createdAt),
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 요약/원문 토글
            if (note.summary != null) ...[
              Row(
                children: [
                  _buildToggleChip(
                    context: context,
                    label: 'AI 요약',
                    icon: Icons.auto_awesome,
                    isSelected: _showSummary,
                    onTap: () => setState(() => _showSummary = true),
                  ),
                  const SizedBox(width: 8),
                  _buildToggleChip(
                    context: context,
                    label: '원문',
                    icon: Icons.format_quote_rounded,
                    isSelected: !_showSummary,
                    onTap: () => setState(() => _showSummary = false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppShapes.large),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _showSummary && note.summary != null
                            ? Icons.auto_awesome
                            : Icons.format_quote_rounded,
                        size: 18,
                        color: _showSummary && note.summary != null
                            ? context.colors.tertiary
                            : context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showSummary && note.summary != null ? 'AI 요약' : '원문',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _showSummary && note.summary != null
                              ? context.colors.tertiary
                              : context.colors.primary,
                        ),
                      ),
                      const Spacer(),
                      // 원문일 때만 수정 버튼 표시
                      if (!_showSummary || note.summary == null)
                        TextButton.icon(
                          icon: Icon(
                            _isEditingContent ? Icons.close : Icons.edit_rounded,
                            size: 16,
                          ),
                          label: Text(_isEditingContent ? '취소' : '수정'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            if (_isEditingContent) {
                              _contentController.text = note.content;
                            }
                            setState(() => _isEditingContent = !_isEditingContent);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_isEditingContent && (!_showSummary || note.summary == null))
                    Column(
                      children: [
                        TextField(
                          controller: _contentController,
                          maxLines: null,
                          minLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: context.colors.onSurface,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: context.surfaceContainerLow,
                            contentPadding: const EdgeInsets.all(AppSpacing.md),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppShapes.medium),
                              borderSide: BorderSide.none,
                            ),
                            hintText: '본문을 수정하세요...',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveContent,
                            child: const Text('저장'),
                          ),
                        ),
                      ],
                    )
                  else
                    SelectableText(
                      _showSummary && note.summary != null
                          ? note.summary!
                          : note.content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: context.colors.onSurface,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 메모
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 메모',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                if (!_isEditingMemo)
                  TextButton.icon(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('수정'),
                    onPressed: () => setState(() => _isEditingMemo = true),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_isEditingMemo)
              Column(
                children: [
                  TextField(
                    controller: _memoController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.onSurface,
                    ),
                    decoration: const InputDecoration(
                      hintText: '이 문장에 대한 생각을 적어보세요...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _memoController.text = note.memo ?? '';
                          setState(() => _isEditingMemo = false);
                        },
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveMemo,
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: note.memo?.isNotEmpty == true
                      ? context.surfaceContainerLowest
                      : context.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppShapes.large),
                  border: note.memo?.isNotEmpty == true
                      ? null
                      : Border.all(
                          color: context.colors.outlineVariant,
                          style: BorderStyle.solid,
                        ),
                ),
                child: Text(
                  note.memo?.isNotEmpty == true
                      ? note.memo!
                      : '아직 메모가 없습니다. 수정 버튼을 눌러 메모를 추가해보세요.',
                  style: TextStyle(
                    fontSize: 15,
                    color: note.memo?.isNotEmpty == true
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),

            // 태그
            if (note.tags.isNotEmpty) ...[
              Text(
                '태그',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: note.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppShapes.medium),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppShapes.full),
          border: Border.all(
            color: isSelected ? context.colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
