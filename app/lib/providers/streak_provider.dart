/// 스트릭 상태 관리 Provider
///
/// 연속 독서 일수 추적 및 넛지 레벨 계산을 담당합니다.
/// Riverpod을 사용하여 상태를 관리합니다.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/streak.dart';
import '../models/nudge.dart';
import '../services/streak_service.dart';
import 'auth_provider.dart';

/// 스트릭 서비스 인스턴스 Provider
final streakServiceProvider = Provider<StreakService>((ref) => StreakService());

/// 현재 스트릭 데이터 Provider
///
/// 사용자의 연속 독서 일수와 최장 기록을 조회합니다.
/// 인증된 사용자가 없으면 null을 반환합니다.
final streakProvider = FutureProvider<StreakData?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.user == null) return null;

  final streakService = ref.watch(streakServiceProvider);
  return streakService.getStreak(authState.user!.id);
});

/// 스트릭 상태 클래스
class StreakState {
  final StreakData? data;
  final bool isLoading;
  final String? errorMessage;

  const StreakState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  StreakState copyWith({
    StreakData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StreakState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 스트릭 상태 관리 StateNotifier
///
/// 스트릭 데이터의 조회, 업데이트, 재계산을 담당합니다.
class StreakNotifier extends StateNotifier<StreakState> {
  final Ref _ref;

  StreakNotifier(this._ref) : super(const StreakState());

  /// 스트릭 데이터를 로드합니다.
  Future<void> loadStreak() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final streakService = _ref.read(streakServiceProvider);
      final streak = await streakService.getStreak(authState.user!.id);
      state = StreakState(data: streak, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '스트릭 데이터를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 활동 후 스트릭을 업데이트합니다.
  ///
  /// 노트 작성 후 호출되어 스트릭을 갱신합니다.
  Future<void> updateAfterActivity() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    try {
      final streakService = _ref.read(streakServiceProvider);
      final updatedStreak =
          await streakService.updateStreak(authState.user!.id);
      state = StreakState(data: updatedStreak, isLoading: false);

      // streakProvider도 갱신
      _ref.invalidate(streakProvider);
    } catch (e) {
      // 스트릭 업데이트 실패는 조용히 무시 (노트 작성은 성공했으므로)
    }
  }

  /// 스트릭을 재계산합니다.
  ///
  /// 앱 시작 시 또는 데이터 무결성 확인이 필요할 때 호출합니다.
  Future<void> recalculateStreak() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final streakService = _ref.read(streakServiceProvider);
      final streak =
          await streakService.recalculateStreak(authState.user!.id);
      state = StreakState(data: streak, isLoading: false);

      // streakProvider도 갱신
      _ref.invalidate(streakProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '스트릭 재계산에 실패했습니다.',
      );
    }
  }
}

/// 스트릭 StateNotifier Provider
final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref);
});

/// 현재 넛지 레벨 Provider
///
/// 스트릭 데이터를 기반으로 넛지 레벨을 자동 계산합니다.
final nudgeLevelProvider = Provider<NudgeLevel>((ref) {
  final streakAsync = ref.watch(streakProvider);

  return streakAsync.whenOrNull(
        data: (streak) {
          if (streak == null) return NudgeLevel.normal;
          return NudgeLevelExtension.fromInactiveDays(streak.inactiveDays);
        },
      ) ??
      NudgeLevel.normal;
});

/// 오늘 활동 여부 Provider
final isActiveTodayProvider = Provider<bool>((ref) {
  final streakAsync = ref.watch(streakProvider);

  return streakAsync.whenOrNull(
        data: (streak) => streak?.isActiveToday ?? false,
      ) ??
      false;
});
