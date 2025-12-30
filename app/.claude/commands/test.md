# 테스트 실행

TEST_PLAN.md를 참고하여 테스트를 실행합니다.

## 실행 순서

1. 먼저 빠른 통과 확인을 실행합니다:
```bash
flutter test && echo "✅ All passed" || echo "❌ Failed"
```

2. 실패한 경우에만 상세 출력을 확인합니다.

3. 인자가 있으면 해당 영역만 테스트합니다:
   - `models` → `flutter test test/models/`
   - `providers` → `flutter test test/providers/`
   - `screens` → `flutter test test/screens/`
   - `core` → `flutter test test/core/`
   - `all` → `flutter test`

## 참고 파일
- TEST_PLAN.md: 테스트 전략 및 구조
- test/mocks/: Fake 서비스 및 테스트 픽스처
