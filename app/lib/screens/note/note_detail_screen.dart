import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  bool _isEditing = false;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 삭제'),
        content: const Text('이 노트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await deleteNote(ref, widget.noteId);
              if (success && mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('노트가 삭제되었습니다')),
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

  Future<void> _saveMemo() async {
    final success = await updateNote(
      ref,
      widget.noteId,
      memo: _memoController.text,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메모가 저장되었습니다')),
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
        body: const Center(child: Text('노트를 찾을 수 없습니다')),
      );
    }

    // 메모 컨트롤러 초기화
    if (!_isEditing && _memoController.text != (note.memo ?? '')) {
      _memoController.text = note.memo ?? '';
    }

    final book = ref.watch(bookProvider(note.bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('노트'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 정보
            if (book != null)
              Card(
                child: ListTile(
                  leading: book.coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            book.coverImage!,
                            width: 40,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.menu_book),
                        ),
                  title: Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(book.author),
                  trailing: note.pageNumber != null
                      ? Chip(label: Text('p.${note.pageNumber}'))
                      : null,
                ),
              ),
            const SizedBox(height: 16),

            // 날짜
            Text(
              dateFormat.format(note.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),

            // 요약/원문 토글
            if (note.summary != null) ...[
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('AI 요약'),
                    selected: _showSummary,
                    onSelected: (selected) {
                      if (selected) setState(() => _showSummary = true);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('원문'),
                    selected: !_showSummary,
                    onSelected: (selected) {
                      if (selected) setState(() => _showSummary = false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _showSummary && note.summary != null
                            ? Icons.auto_awesome
                            : Icons.format_quote,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showSummary && note.summary != null ? 'AI 요약' : '원문',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _showSummary && note.summary != null
                        ? note.summary!
                        : note.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 메모
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 메모',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('수정'),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              Column(
                children: [
                  TextField(
                    controller: _memoController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '이 문장에 대한 생각을 적어보세요...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _memoController.text = note.memo ?? '';
                          setState(() => _isEditing = false);
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note.memo?.isNotEmpty == true
                      ? note.memo!
                      : '아직 메모가 없습니다. 수정 버튼을 눌러 메모를 추가해보세요.',
                  style: TextStyle(
                    color: note.memo?.isNotEmpty == true
                        ? null
                        : Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 태그
            if (note.tags.isNotEmpty) ...[
              Text(
                '태그',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: note.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
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
}
