import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TossColors.gray900,
          ),
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            fontSize: 15,
            color: TossColors.gray700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: TossColors.gray600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: TossColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final booksAsync = ref.watch(booksProvider);
    final notesAsync = ref.watch(notesProvider);
    final noteCountsAsync = ref.watch(noteCountsByDateProvider(_selectedYear));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '안녕하세요',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TossColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authState.user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: TossColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: TossColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 통계 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book_rounded,
                        label: '등록한 책',
                        value: booksAsync.whenOrNull(
                              data: (books) => books.length.toString(),
                            ) ??
                            '-',
                        color: TossColors.blue,
                        bgColor: TossColors.blueLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.format_quote_rounded,
                        label: '수집한 문장',
                        value: notesAsync.whenOrNull(
                              data: (notes) => notes.length.toString(),
                            ) ??
                            '-',
                        color: TossColors.orange,
                        bgColor: TossColors.orangeLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 활동 캘린더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TossColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: noteCountsAsync.when(
                    data: (counts) => ActivityCalendar(
                      year: _selectedYear,
                      data: counts,
                      onYearChanged: (year) {
                        setState(() => _selectedYear = year);
                      },
                    ),
                    loading: () => const SizedBox(
                      height: 140,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: TossColors.blue,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          '캘린더를 불러오지 못했습니다',
                          style: TextStyle(color: TossColors.gray500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 최근 활동 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  '최근 수집한 문장',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TossColors.gray900,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 최근 노트 목록
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: TossColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: TossColors.gray100,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: const Icon(
                                  Icons.format_quote_rounded,
                                  size: 32,
                                  color: TossColors.gray400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '아직 수집한 문장이 없어요',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: TossColors.gray700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '책을 등록하고 마음에 드는 문장을 저장해보세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TossColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final recentNotes = notes.take(3).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TossColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: recentNotes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final note = entry.value;
                          final book = ref.watch(bookProvider(note.bookId));
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/notes/${note.id}'),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: TossColors.blueLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.format_quote_rounded,
                                        size: 20,
                                        color: TossColors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.summary ?? note.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: TossColors.gray800,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            book?.title ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: TossColors.gray500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              ),
                              if (index < recentNotes.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: 68,
                                  color: TossColors.gray200,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: TossColors.blue,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      '불러오기 실패',
                      style: TextStyle(color: TossColors.gray500),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
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
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: TossColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: TossColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
