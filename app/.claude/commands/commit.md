---
description: 변경사항 커밋 (Conventional Commits)
allowed-tools: Bash(git:*)
---

# Smart Commit

현재 변경사항을 분석하고 적절한 커밋 메시지를 생성합니다.

## 현재 상태
- 브랜치: !`git branch --show-current`
- Staged: !`git diff --cached --stat`
- Unstaged: !`git diff --stat`
- Untracked: !`git ls-files --others --exclude-standard`

## 최근 커밋 스타일
```
!`git log --oneline -10`
```

## Commit Convention

```
<type>: <subject>

[optional body]

🤖 Generated with Claude Code
```

### Types
- `feat`: 새 기능
- `fix`: 버그 수정
- `refactor`: 리팩토링 (기능 변화 없음)
- `test`: 테스트 추가/수정
- `docs`: 문서 변경
- `chore`: 빌드, 설정 등
- `style`: 포맷팅, 세미콜론 등

### Rules
- Subject는 50자 이내
- 명령형 사용 ("Add feature" not "Added feature")
- Body는 "왜"를 설명 (무엇은 diff로 볼 수 있음)

## 작업 순서

1. **변경사항 확인** - Staged, Unstaged, Untracked 모두 확인
2. **변경사항 없으면 즉시 알림** (아래 형식)
3. 변경사항 있으면 → type 선택 → subject 작성 → 커밋

## 변경사항 없을 때

위 "현재 상태"에서 Staged, Unstaged, Untracked가 모두 비어있으면:

```
✅ 커밋할 변경사항이 없습니다.

현재 상태:
- Working tree clean
- 마지막 커밋: [최근 커밋 메시지]
```

이 메시지를 출력하고 작업을 종료합니다. 추가 작업 없이 바로 알려주세요.

## 주의사항

- `.env`, `credentials` 등 민감한 파일 제외 확인
- 큰 변경은 여러 커밋으로 분리 고려
