import 'package:flutter/material.dart';

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

  /// 활동량에 따른 색상 반환
  Color _getColor(int count, BuildContext context) {
    if (count == 0) return Colors.grey.shade200;
    if (count <= 3) return Colors.orange.shade100;
    if (count <= 8) return Colors.orange.shade200;
    if (count <= 15) return Colors.orange.shade300;
    if (count <= 30) return Colors.orange.shade400;
    return Colors.orange.shade600;
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onYearChanged?.call(year - 1),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: year < now.year
                      ? () => onYearChanged?.call(year + 1)
                      : null,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 요일 레이블
        Row(
          children: [
            const SizedBox(width: 24),
            ...['일', '월', '화', '수', '목', '금', '토'].map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 캘린더 그리드
        SizedBox(
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // 최근 날짜가 오른쪽에 오도록
            child: Row(
              children: [
                // 월 레이블
                SizedBox(
                  width: 24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) => const SizedBox()),
                  ),
                ),
                // 주별 컬럼
                ...weeks.map((week) {
                  return Column(
                    children: week.map((date) {
                      if (date == null) {
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(1),
                        );
                      }

                      final dateKey =
                          DateTime(date.year, date.month, date.day);
                      final count = data[dateKey] ?? 0;

                      return Tooltip(
                        message:
                            '${date.month}/${date.day}: $count개',
                        child: Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: _getColor(count, context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '적음',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 4),
            ...[0, 3, 8, 15, 31].map(
              (count) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _getColor(count, context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '많음',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
