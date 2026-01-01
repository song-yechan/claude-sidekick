import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// GitHub 스타일 활동 캘린더 위젯
class ActivityCalendar extends StatelessWidget {
  final int year;
  final Map<DateTime, int> data;
  final Function(int)? onYearChanged;

  const ActivityCalendar({
    super.key,
    required this.year,
    required this.data,
    this.onYearChanged,
  });

  /// 월 영어 약어
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// 요일 라벨 (일, 월, 화, 수, 목, 금, 토 중 월, 수, 금만 표시)
  static const _dayLabels = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

  /// 활동량에 따른 색상 반환 (다크모드 대응)
  Color _getColor(BuildContext context, int count) {
    final isDark = context.isDark;
    final baseColor = context.colors.primary;
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
    final startDate = DateTime(year, 1, 1);
    // 항상 12월 31일까지 그리드 표시 (미래 날짜는 빈 칸)
    final endDate = DateTime(year, 12, 31);

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

    const cellSize = 11.0;
    const cellMargin = 1.5;
    const dayLabelWidth = 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 연도 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$year년 독서 활동',
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
                  onTap: () => onYearChanged?.call(year - 1),
                ),
                const SizedBox(width: 4),
                _YearButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: year < now.year
                      ? () => onYearChanged?.call(year + 1)
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
                        height: cellSize + cellMargin * 2,
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
                              width: cellSize + cellMargin * 2,
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
                                  width: cellSize,
                                  height: cellSize,
                                  margin: const EdgeInsets.all(cellMargin),
                                );
                              }

                              final dateKey =
                                  DateTime(date.year, date.month, date.day);

                              // 미래 날짜는 빈 칸으로 표시
                              final isFuture = dateKey.isAfter(today);
                              if (isFuture) {
                                return Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: const EdgeInsets.all(cellMargin),
                                );
                              }

                              final count = data[dateKey] ?? 0;

                              return Tooltip(
                                message: '${date.month}월 ${date.day}일: $count개',
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: const EdgeInsets.all(cellMargin),
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
