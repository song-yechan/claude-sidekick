---
description: 현재 변경사항 코드 리뷰
allowed-tools: Read, Grep, Glob, Bash(git:*)
---

# Code Review

현재 브랜치의 변경사항을 리뷰합니다.

## 현재 상태
- 브랜치: !`git branch --show-current`
- 변경 파일: !`git diff --name-only HEAD~5 2>/dev/null || git diff --name-only`
- 최근 커밋: !`git log --oneline -5`

## 변경 내용
```
!`git diff --stat HEAD~5 2>/dev/null || git diff --stat`
```

## 리뷰 체크리스트

### 코드 품질
- [ ] 코드가 읽기 쉽고 명확한가?
- [ ] 함수/변수명이 적절한가?
- [ ] 중복 코드가 없는가?
- [ ] BookScribe 패턴을 따르는가?

### 보안
- [ ] 하드코딩된 시크릿이 없는가?
- [ ] 입력 검증이 적절한가?
- [ ] SQL 인젝션/XSS 취약점이 없는가?

### 성능
- [ ] 불필요한 리렌더링이 없는가?
- [ ] N+1 쿼리 문제가 없는가?
- [ ] 메모리 누수 가능성이 없는가?

### 테스트
- [ ] 테스트 커버리지가 적절한가?
- [ ] 엣지 케이스가 테스트되었는가?

## 리뷰 결과 형식

### Critical (반드시 수정)
- [파일:라인] 문제 설명 및 수정 방안

### Warning (수정 권장)
- [파일:라인] 문제 설명 및 수정 방안

### Suggestion (고려사항)
- [파일:라인] 개선 제안
