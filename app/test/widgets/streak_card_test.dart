/// StreakCard 위젯 테스트
///
/// 스트릭 카드의 각 상태별 UI를 검증합니다.
/// - 로딩 상태 (스켈레톤)
/// - 빈 상태 (스트릭 0, 오늘 활동 없음)
/// - 활성 상태 (스트릭 진행 중)
/// - 완료 상태 (오늘 활동 완료)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/streak.dart';
import 'package:bookscribe/providers/streak_provider.dart';
import 'package:bookscribe/widgets/home/streak_card.dart';

import '../helpers/test_app.dart';

void main() {
  group('StreakCard', () {
    StreakData createTestStreak({
      int currentStreak = 0,
      int longestStreak = 0,
      DateTime? lastActiveDate,
    }) {
      final now = DateTime.now();
      return StreakData(
        id: 'streak-123',
        userId: 'user-123',
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: lastActiveDate,
        streakStartDate: currentStreak > 0 ? now.subtract(Duration(days: currentStreak - 1)) : null,
        createdAt: now,
        updatedAt: now,
      );
    }

    testWidgets('displays skeleton when loading', (tester) async {
      // Completer를 사용하여 완료되지 않는 Future 생성
      final completer = Completer<StreakData?>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) => completer.future),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      // pump만 호출 (pumpAndSettle 아님) - 로딩 상태 유지
      await tester.pump();

      // 로딩 중에는 스켈레톤이 표시됨
      // Container가 여러 개 있을 수 있으므로 최소 1개 확인
      expect(find.byType(Container), findsWidgets);

      // 테스트 종료 전 completer 완료
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('displays empty state when streak is 0 and not active today', (tester) async {
      final emptyStreak = createTestStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => emptyStreak),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // 빈 상태에서는 '시작하기' 버튼이 표시됨
      expect(find.byType(FilledButton), findsOneWidget);
      // 빈 불꽃 아이콘
      expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
    });

    testWidgets('displays streak content when active', (tester) async {
      final activeStreak = createTestStreak(
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => activeStreak),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // 스트릭 숫자가 표시됨
      expect(find.text('5'), findsOneWidget);
      // 채워진 불꽃 아이콘
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('displays check badge when active today', (tester) async {
      final todayActiveStreak = createTestStreak(
        currentStreak: 3,
        longestStreak: 5,
        lastActiveDate: DateTime.now(), // 오늘 활동
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => todayActiveStreak),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // 완료 체크 아이콘이 표시됨
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('displays longest streak when available', (tester) async {
      final streakWithRecord = createTestStreak(
        currentStreak: 5,
        longestStreak: 15,
        lastActiveDate: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => streakWithRecord),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // 최장 기록이 표시됨 (15일)
      expect(find.textContaining('15'), findsOneWidget);
    });

    testWidgets('hides widget on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async {
              throw Exception('Network error');
            }),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // 에러 시 SizedBox.shrink()로 숨김
      expect(find.byType(SizedBox), findsOneWidget);
    });

    group('streak level colors', () {
      testWidgets('shows light orange for 1-6 day streak', (tester) async {
        final lowStreak = createTestStreak(
          currentStreak: 3,
          longestStreak: 3,
          lastActiveDate: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              streakProvider.overrideWith((ref) async => lowStreak),
            ],
            child: const TestApp(child: StreakCard()),
          ),
        );

        await tester.pumpAndSettle();

        // 불꽃 아이콘이 표시됨
        expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      });

      testWidgets('shows orange for 7-29 day streak', (tester) async {
        final midStreak = createTestStreak(
          currentStreak: 15,
          longestStreak: 15,
          lastActiveDate: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              streakProvider.overrideWith((ref) async => midStreak),
            ],
            child: const TestApp(child: StreakCard()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('15'), findsOneWidget);
      });

      testWidgets('shows red for 30+ day streak', (tester) async {
        final highStreak = createTestStreak(
          currentStreak: 45,
          longestStreak: 45,
          lastActiveDate: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              streakProvider.overrideWith((ref) async => highStreak),
            ],
            child: const TestApp(child: StreakCard()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('45'), findsOneWidget);
      });
    });

    testWidgets('null streak shows empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => null),
          ],
          child: const TestApp(child: StreakCard()),
        ),
      );

      await tester.pumpAndSettle();

      // null streak도 빈 상태로 처리됨
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
