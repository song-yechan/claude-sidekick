import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// GitHub 스타일 활동 캘린더 위젯
class ActivityCalendar extends StatefulWidget {
  final int year;
  final Map<DateTime, int> data;
  final Function(int)? onYearChanged;

  const ActivityCalendar({
    super.key,
    required this.year,
    required this.data,
    this.onYearChanged,
  });

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  late ScrollController _scrollController;

  /// 월 영어 약어
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// 요일 라벨 (일, 월, 화, 수, 목, 금, 토 중 월, 수, 금만 표시)
  static const _dayLabels = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

  static const _cellSize = 11.0;
  static const _cellMargin = 1.5;
  static const _cellTotalSize = _cellSize + _cellMargin * 2;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void didUpdateWidget(ActivityCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 오늘 날짜가 중앙에 오도록 스크롤
  void _scrollToToday() {
    if (!_scrollController.hasClients) return;

    final now = DateTime.now();
    final startDate = DateTime(widget.year, 1, 1);

    // 현재 연도가 아니면 끝으로 스크롤
    if (widget.year != now.year) {
      _scrollController.jumpTo(0); // reverse: true이므로 0이 끝
      return;
    }

    // 오늘까지의 주 수 계산
    final firstDayOfWeek = startDate.weekday % 7;
    final daysSinceStart = now.difference(startDate).inDays;
    final weekIndex = (daysSinceStart + firstDayOfWeek) ~/ 7;

    // 전체 주 수
    final totalWeeks = 53; // 1년은 최대 53주

    // 오늘 위치의 오프셋 (오른쪽 끝에서부터)
    final todayOffset = (totalWeeks - weekIndex - 1) * _cellTotalSize;

    // 화면 너비의 절반만큼 빼서 중앙에 오도록
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = todayOffset - (viewportWidth / 2) + (_cellTotalSize / 2);

    // 범위 내로 제한
    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.jumpTo(clampedOffset);
  }

  /// 활동량에 따른 색상 반환 (다크모드 대응)
  Color _getColor(BuildContext context, int count, {bool isFuture = false}) {
    final isDark = context.isDark;
    final baseColor = context.colors.primary;

    // 미래 날짜는 더 연한 색상으로 구분
    if (isFuture) {
      return isDark
          ? const Color(0xFF1E1E20)  // 다크모드: 더 어두운 색
          : context.colors.outlineVariant.withValues(alpha: 0.3);  // 라이트모드: 연한 테두리색
    }

    final emptyColor = isDark
        ? const Color(0xFF2B292D)
        : context.surfaceContainerHigh;

    if (count == 0) return emptyColor;
    if (count <= 2) return baseColor.withValues(alpha: 0.25);
    if (count <= 5) return baseColor.withValues(alpha: 0.45);
    if (count <= 10) return baseColor.withValues(alpha: 0.65);
    if (count <= 20) return baseColor.withValues(alpha: 0.85);
    return baseColor;
  }

  /// 주어진 주가 새로운 달의 시작인지 확인하고, 해당 월 반환
  int? _getMonthForWeek(List<DateTime?> week, List<DateTime?> previousWeek) {
    for (final date in week) {
      if (date != null && date.day <= 7) {
        // 이전 주에 같은 월이 없으면 새로운 달의 시작
        final hasSameMonthInPrevWeek = previousWeek.any(
            (d) => d != null && d.month == date.month && d.year == date.year);
        if (!hasSameMonthInPrevWeek) {
          return date.month;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(widget.year, 1, 1);
    // 항상 12월 31일까지 그리드 표시 (미래 날짜는 빈 칸)
    final endDate = DateTime(widget.year, 12, 31);

    // 주별로 그룹화
    final weeks = <List<DateTime?>>[];
    var currentWeek = <DateTime?>[];

    // 첫 주의 시작을 일요일에 맞추기 위해 빈 칸 추가
    final firstDayOfWeek = startDate.weekday % 7;
    for (var i = 0; i < firstDayOfWeek; i++) {
      currentWeek.add(null);
    }

    // 날짜 추가
    for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      currentWeek.add(date);

      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    // 마지막 주 처리
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    // 각 주의 월 라벨 계산
    final monthLabelsForWeeks = <int?>[];
    for (var i = 0; i < weeks.length; i++) {
      final previousWeek = i > 0 ? weeks[i - 1] : <DateTime?>[];
      monthLabelsForWeeks.add(_getMonthForWeek(weeks[i], previousWeek));
    }

    const dayLabelWidth = 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 연도 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.year}년 독서 활동',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            Row(
              children: [
                _YearButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => widget.onYearChanged?.call(widget.year - 1),
                ),
                const SizedBox(width: 4),
                _YearButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: widget.year < now.year
                      ? () => widget.onYearChanged?.call(widget.year + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 캘린더 그리드 (요일 라벨 + 스크롤 가능한 그래프)
        SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 고정된 요일 라벨
              SizedBox(
                width: dayLabelWidth,
                child: Column(
                  children: [
                    // 월 라벨 영역과 높이 맞추기
                    const SizedBox(height: 16),
                    // 요일 라벨
                    ...List.generate(7, (index) {
                      return SizedBox(
                        height: _cellTotalSize,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _dayLabels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 스크롤 가능한 캘린더 영역
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 월 라벨 행
                      SizedBox(
                        height: 16,
                        child: Row(
                          children: weeks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final month = monthLabelsForWeeks[index];
                            return SizedBox(
                              width: _cellTotalSize,
                              child: month != null
                                  ? Text(
                                      _monthLabels[month - 1],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                      ),

                      // 캘린더 그리드
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: weeks.map((week) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: week.map((date) {
                              if (date == null) {
                                return Container(
                                  width: _cellSize,
                                  height: _cellSize,
                                  margin: const EdgeInsets.all(_cellMargin),
                                );
                              }

                              final dateKey =
                                  DateTime(date.year, date.month, date.day);

                              // 미래 날짜 체크
                              final isFuture = dateKey.isAfter(today);

                              if (isFuture) {
                                return Tooltip(
                                  message: '${date.month}월 ${date.day}일',
                                  child: Container(
                                    width: _cellSize,
                                    height: _cellSize,
                                    margin: const EdgeInsets.all(_cellMargin),
                                    decoration: BoxDecoration(
                                      color: _getColor(context, 0, isFuture: true),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }

                              final count = widget.data[dateKey] ?? 0;

                              return Tooltip(
                                message: '${date.month}월 ${date.day}일: $count개',
                                child: Container(
                                  width: _cellSize,
                                  height: _cellSize,
                                  margin: const EdgeInsets.all(_cellMargin),
                                  decoration: BoxDecoration(
                                    color: _getColor(context, count),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '적음',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            ...[0, 2, 5, 10, 21].map(
              (count) => Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getColor(context, count),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '많음',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _YearButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _YearButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? context.surfaceContainerHigh
              : context.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppShapes.small),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? context.colors.onSurfaceVariant
              : context.colors.outlineVariant,
        ),
      ),
    );
  }
}
