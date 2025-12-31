---
description: GitHub 이슈 기반 기능 구현
argument-hint: [issue-number]
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# Feature Implementation

GitHub 이슈 #$1 을 구현합니다.

## 현재 상태
- 브랜치: !`git branch --show-current`
- 변경사항: !`git status --short`

## 작업 프로세스

1. **이슈 분석**: GitHub 이슈 #$1 의 요구사항을 파악
2. **영향 분석**: 관련 코드 탐색 및 변경 범위 파악
3. **구현**: BookScribe 패턴에 맞게 구현
4. **테스트**: 필요한 테스트 작성
5. **검증**: flutter analyze 및 테스트 실행

## 구현 기준

- `lib/core/` - 설정, 테마, 상수
- `lib/models/` - 데이터 모델
- `lib/providers/` - Riverpod StateNotifier
- `lib/services/` - API 호출
- `lib/screens/` - 화면 위젯
- `lib/widgets/` - 재사용 위젯

## 완료 조건

- [ ] 기능 구현 완료
- [ ] flutter analyze 통과
- [ ] 관련 테스트 작성/통과
- [ ] 코드 리뷰 준비 완료
