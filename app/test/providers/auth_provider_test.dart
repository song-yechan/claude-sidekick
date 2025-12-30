import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/providers/auth_provider.dart';

void main() {
  group('getKoreanAuthErrorMessage', () {
    test('잘못된 로그인 정보 에러를 한국어로 변환', () {
      final message = getKoreanAuthErrorMessage(
        'AuthException: Invalid login credentials',
      );
      expect(message, '이메일 또는 비밀번호가 올바르지 않습니다.');
    });

    test('이미 가입된 이메일 에러를 한국어로 변환', () {
      expect(
        getKoreanAuthErrorMessage('User already registered'),
        '이미 가입된 이메일입니다.',
      );
      expect(
        getKoreanAuthErrorMessage('user already exists'),
        '이미 가입된 이메일입니다.',
      );
    });

    test('이메일 인증 필요 에러를 한국어로 변환', () {
      final message = getKoreanAuthErrorMessage('Email not confirmed');
      expect(message, '이메일 인증이 필요합니다.');
    });

    test('잘못된 이메일 형식 에러를 한국어로 변환', () {
      final message = getKoreanAuthErrorMessage('Invalid email format');
      expect(message, '올바른 이메일 형식이 아닙니다.');
    });

    test('비밀번호 길이 에러를 한국어로 변환', () {
      final message = getKoreanAuthErrorMessage(
        'Password should be at least 6 characters',
      );
      expect(message, '비밀번호는 6자 이상이어야 합니다.');
    });

    test('네트워크 에러를 한국어로 변환', () {
      expect(
        getKoreanAuthErrorMessage('Network error occurred'),
        '네트워크 연결을 확인해주세요.',
      );
      expect(
        getKoreanAuthErrorMessage('Connection failed'),
        '네트워크 연결을 확인해주세요.',
      );
    });

    test('요청 제한 에러를 한국어로 변환', () {
      expect(
        getKoreanAuthErrorMessage('Too many requests'),
        '잠시 후 다시 시도해주세요.',
      );
      expect(
        getKoreanAuthErrorMessage('Rate limit exceeded'),
        '잠시 후 다시 시도해주세요.',
      );
    });

    test('알 수 없는 에러는 기본 메시지 반환', () {
      final message = getKoreanAuthErrorMessage('Unknown error xyz123');
      expect(message, '오류가 발생했습니다. 다시 시도해주세요.');
    });

    test('대소문자 구분 없이 처리', () {
      expect(
        getKoreanAuthErrorMessage('INVALID LOGIN CREDENTIALS'),
        '이메일 또는 비밀번호가 올바르지 않습니다.',
      );
    });
  });

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
