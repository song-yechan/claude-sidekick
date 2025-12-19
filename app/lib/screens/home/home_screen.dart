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
                        Text(
                          '안녕하세요',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authState.user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.push('/settings'),
                      icon: Icon(
                        Icons.settings_rounded,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

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
                        color: context.colors.primary,
                        bgColor: context.colors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.format_quote_rounded,
                        label: '수집한 문장',
                        value: notesAsync.whenOrNull(
                              data: (notes) => notes.length.toString(),
                            ) ??
                            '-',
                        color: context.colors.tertiary,
                        bgColor: context.colors.tertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 활동 캘린더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppShapes.large),
                  ),
                  child: noteCountsAsync.when(
                    data: (counts) => ActivityCalendar(
                      year: _selectedYear,
                      data: counts,
                      onYearChanged: (year) {
                        setState(() => _selectedYear = year);
                      },
                    ),
                    loading: () => SizedBox(
                      height: 140,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (_, __) => SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          '캘린더를 불러오지 못했습니다',
                          style: TextStyle(color: context.colors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 최근 활동 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '최근 수집한 문장',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 최근 노트 목록
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: context.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppShapes.large),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: context.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Icon(
                                  Icons.format_quote_rounded,
                                  size: 32,
                                  color: context.colors.outline,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                '아직 수집한 문장이 없어요',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '책을 등록하고 마음에 드는 문장을 저장해보세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.onSurfaceVariant,
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
                        color: context.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppShapes.large),
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
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: context.colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.format_quote_rounded,
                                        size: 20,
                                        color: context.colors.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note.summary ?? note.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: context.colors.onSurface,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            book?.title ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.colors.onSurfaceVariant,
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
                                Divider(
                                  height: 1,
                                  indent: 68,
                                  color: context.colors.outlineVariant,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      '불러오기 실패',
                      style: TextStyle(color: context.colors.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
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
        color: context.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppShapes.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppShapes.medium),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
