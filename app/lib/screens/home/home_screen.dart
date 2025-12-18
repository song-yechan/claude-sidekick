import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/common/activity_calendar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final booksAsync = ref.watch(booksProvider);
    final notesAsync = ref.watch(notesProvider);
    final noteCountsAsync = ref.watch(noteCountsByDateProvider(_selectedYear));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookScan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authProvider.notifier).signOut();
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지
            Text(
              '안녕하세요!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              authState.user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),

            // 통계 카드
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.book,
                    label: '등록한 책',
                    value: booksAsync.whenOrNull(
                          data: (books) => books.length.toString(),
                        ) ??
                        '-',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.note,
                    label: '수집한 문장',
                    value: notesAsync.whenOrNull(
                          data: (notes) => notes.length.toString(),
                        ) ??
                        '-',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 활동 캘린더
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: noteCountsAsync.when(
                  data: (counts) => ActivityCalendar(
                    year: _selectedYear,
                    data: counts,
                    onYearChanged: (year) {
                      setState(() => _selectedYear = year);
                    },
                  ),
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox(
                    height: 120,
                    child: Center(child: Text('캘린더를 불러오지 못했습니다')),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 최근 활동
            Text(
              '최근 수집한 문장',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.note_add,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '아직 수집한 문장이 없습니다',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final recentNotes = notes.take(3).toList();
                return Column(
                  children: recentNotes.map((note) {
                    final book = ref.watch(bookProvider(note.bookId));
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.format_quote),
                        title: Text(
                          note.summary ?? note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          book?.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('불러오기 실패'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
