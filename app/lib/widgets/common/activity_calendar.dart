import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// 토스 스타일 활동 캘린더 위젯
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

  /// 활동량에 따른 색상 반환
  Color _getColor(int count) {
    if (count == 0) return TossColors.gray100;
    if (count <= 2) return TossColors.blue.withValues(alpha: 0.2);
    if (count <= 5) return TossColors.blue.withValues(alpha: 0.4);
    if (count <= 10) return TossColors.blue.withValues(alpha: 0.6);
    if (count <= 20) return TossColors.blue.withValues(alpha: 0.8);
    return TossColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = DateTime(year, 1, 1);
    final endDate = year == now.year ? now : DateTime(year, 12, 31);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 연도 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$year년 독서 활동',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TossColors.gray900,
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
        const SizedBox(height: 16),

        // 캘린더 그리드
        SizedBox(
          height: 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: weeks.map((week) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: week.map((date) {
                    if (date == null) {
                      return Container(
                        width: 11,
                        height: 11,
                        margin: const EdgeInsets.all(1.5),
                      );
                    }

                    final dateKey = DateTime(date.year, date.month, date.day);
                    final count = data[dateKey] ?? 0;

                    return Tooltip(
                      message: '${date.month}월 ${date.day}일: $count개',
                      child: Container(
                        width: 11,
                        height: 11,
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: _getColor(count),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              '적음',
              style: TextStyle(
                fontSize: 11,
                color: TossColors.gray500,
              ),
            ),
            const SizedBox(width: 6),
            ...[0, 2, 5, 10, 21].map(
              (count) => Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getColor(count),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '많음',
              style: TextStyle(
                fontSize: 11,
                color: TossColors.gray500,
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
          color: onTap != null ? TossColors.gray100 : TossColors.gray50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? TossColors.gray700 : TossColors.gray300,
        ),
      ),
    );
  }
}
