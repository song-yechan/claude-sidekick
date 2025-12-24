import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('기본 생성자는 미인증 상태', () {
      const state = AuthState();

      expect(state.user, isNull);
      expect(state.session, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.signUpCompleted, isFalse);
      expect(state.isAuthenticated, isFalse);
    });

    test('isLoading이 true인 상태', () {
      const state = AuthState(isLoading: true);

      expect(state.isLoading, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('copyWith으로 isLoading 변경', () {
      const state = AuthState();
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
      expect(newState.user, isNull);
      expect(newState.errorMessage, isNull);
    });

    test('copyWith으로 errorMessage 설정', () {
      const state = AuthState(isLoading: true);
      final newState = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 실패',
      );

      expect(newState.isLoading, isFalse);
      expect(newState.errorMessage, '로그인 실패');
    });

    test('copyWith으로 errorMessage를 null로 초기화 (새 값 전달 시)', () {
      const state = AuthState(errorMessage: '기존 에러');
      // copyWith에서 errorMessage는 전달된 값을 사용 (null 포함)
      final newState = state.copyWith(errorMessage: null);

      // 이 경우 errorMessage는 null이 됨
      expect(newState.errorMessage, isNull);
    });

    test('signUpCompleted가 true이면 isAuthenticated는 false', () {
      // signUpCompleted가 true이면 회원가입 완료 화면을 보여주기 위해
      // isAuthenticated는 false를 반환 (user가 있어도)
      const state = AuthState(signUpCompleted: true);

      expect(state.signUpCompleted, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('copyWith으로 signUpCompleted 변경', () {
      const state = AuthState(signUpCompleted: true);
      final newState = state.copyWith(signUpCompleted: false);

      expect(newState.signUpCompleted, isFalse);
    });
  });
}
