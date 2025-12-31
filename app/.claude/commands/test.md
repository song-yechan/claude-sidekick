---
description: 특정 모듈의 테스트 생성 및 실행
argument-hint: [module-name]
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# Test Generation & Execution

`$1` 모듈에 대한 테스트를 생성하고 실행합니다.

## 현재 테스트 상태
```
!`flutter test --machine 2>/dev/null | head -20 || echo "테스트 실행 필요"`
```

## 대상 모듈
- 모듈명: `$1`
- 관련 파일: `lib/**/*$1*`
- 기존 테스트: `test/**/*$1*`

## 테스트 유형

### 1. Unit Tests (models, services)
```dart
group('$1', () {
  test('should ...', () {
    // Arrange
    // Act
    // Assert
  });
});
```

### 2. Provider Tests (providers)
```dart
test('$1 provider', () async {
  final container = ProviderContainer(overrides: [...]);
  // Test provider behavior
});
```

### 3. Widget Tests (screens, widgets)
```dart
testWidgets('$1 widget', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp(home: $1Widget())),
  );
  // Test widget behavior
});
```

## 테스트 작성 기준

- Happy path 테스트
- Error handling 테스트
- Edge case 테스트
- Mock 사용 (mockito)

## 실행 명령

```bash
# 특정 테스트 실행
flutter test test/**/*$1*

# 전체 테스트 + 커버리지
flutter test --coverage
```

## 완료 조건

- [ ] 테스트 파일 생성/수정
- [ ] 모든 테스트 통과
- [ ] 커버리지 유지/개선
