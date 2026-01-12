# CLAUDE.md - BookScribe 프로젝트 가이드

## 0. 최우선 규칙

### 0-1. 의사결정 요청

Claude Code가 **의사결정이 필요한 모든 상황**에서 반드시 수행:

### 0-2. 진행 현황 표시

**5분 이상 소요되는 큰 작업** 시 사용자 요청 없이도 진행 바 표시:

```
[████████░░░░░░░░] 50% (5/10 파일 완료)
```

- 파일 단위, 단계 단위로 업데이트
- 완료된 항목과 남은 항목 명시
- Todo List도 함께 활용

1. **현재 상태 요약** - 작업 목적, 단계, 확정/미확정 사항
2. **의사결정 필요 이유** - 기술적/UX/리소스 제약 명시
3. **선택지 제시** - 옵션 A/B/C + 각각의 장단점
4. **추천안 필수** - 중립적 질문 금지, 반드시 추천 + 이유 제시

```
👉 추천안: 옵션 B
이유: [구체적 근거]
```

---

## 1. 프로젝트 개요

- **Project**: BookScribe (책 속 문장 수집 앱)
- **Goal**: 책 사진 → OCR → 나만의 독서 노트 생성
- **Users**: 독서를 즐기고 인상 깊은 문장을 기록하고 싶은 사용자

### Tech Stack
- **App**: Flutter 3.10+ / Dart
- **Backend**: Supabase (Auth, Database, Storage, Edge Functions)
- **State**: Riverpod
- **Routing**: go_router
- **OCR**: Google Cloud Vision API
- **Book Search**: Aladin API

---

## 2. 프로젝트 구조

```
book-note-scribe/
├── app/                    # Flutter 앱
│   ├── lib/
│   │   ├── core/           # 상수, 테마, Supabase 클라이언트
│   │   ├── models/         # Book, Note, Category 모델
│   │   ├── providers/      # Riverpod providers
│   │   ├── services/       # API 호출 서비스
│   │   ├── screens/        # 화면 위젯
│   │   └── widgets/        # 재사용 위젯
│   └── test/               # 단위 테스트
├── supabase/
│   ├── functions/          # Edge Functions (Deno)
│   │   ├── ocr-image/      # Google Vision OCR
│   │   ├── book-search/    # Aladin API 검색
│   │   └── summarize-text/ # (미사용)
│   └── migrations/         # DB 마이그레이션
└── web/                    # 웹 버전 (React, 레거시)
```

---

## 3. 핵심 데이터 흐름

### OCR 흐름
```
book_detail_screen.dart
  → _pickImage() (카메라/갤러리)
  → _cropImage() (이미지 자르기)
  → ocr_service.dart → Edge Function(ocr-image)
  → Google Vision API
  → 텍스트 반환
```

### 책 검색 흐름
```
search_screen.dart
  → book_provider.dart (bookSearchProvider)
  → book_service.dart → Edge Function(book-search)
  → Aladin API
  → BookSearchResult 반환
```

### 데이터 의존성
- `Book` 삭제 시 → 해당 `Note` 모두 CASCADE 삭제
- `Note` 삭제 시 → Storage 이미지도 삭제 (note_service.dart에서 처리)
- `Category` 삭제 시 → book_categories 연결만 삭제 (책은 유지)

---

## 4. 주요 파일 변경 시 영향도

| 변경 대상 | 함께 확인할 파일 |
|----------|----------------|
| `Book` 모델 | book_service, book_provider, search_screen |
| `Note` 모델 | note_service, note_provider, book_detail_screen |
| Edge Function | 배포 필요 (`--no-verify-jwt`) |
| DB 스키마 | migrations 폴더에 마이그레이션 추가 |

---

## 5. 배포 규칙

### Edge Functions 배포
```bash
# 반드시 --no-verify-jwt 플래그 사용 (앱에서 JWT 없이 호출)
npx supabase functions deploy <function-name> --no-verify-jwt
```

### iOS 앱 배포
```bash
# 버전 업데이트: pubspec.yaml의 version 수정
flutter build ipa --release
# Xcode에서 Archive 열고 → Distribute App → App Store Connect
```

### Flutter Flavor 추가/수정 시 체크리스트

Flavor(Dev/Prod 등) 관련 작업 시 반드시 확인:

- [ ] `ios/Podfile` - 새 Configuration 추가 (Debug-xxx, Release-xxx, Profile-xxx)
- [ ] `ios/Flutter/*.xcconfig` - Flavor별 xcconfig 생성 및 Pods include 확인
- [ ] `ios/Runner.xcodeproj/project.pbxproj` - Build Configuration 추가
- [ ] `android/app/build.gradle.kts` - productFlavors 추가
- [ ] `pod install` 실행 및 경고 확인
- [ ] 로컬 빌드 테스트 (`flutter build ipa --flavor xxx`)
- [ ] Xcode Cloud 스크립트 경로 확인 (`ci_scripts/ci_post_clone.sh`)

**주의**: 쉘 스크립트 작성 시 `#!/bin/sh` 사용하면 POSIX 호환 문법만 사용
- `&>` → `> /dev/null 2>&1`
- `[[ ]]` → `[ ]`

### DB 마이그레이션
```bash
# 새 마이그레이션 생성
npx supabase migration new <migration_name>
# 마이그레이션 적용 (원격)
npx supabase db push
```

---

## 6. 코딩 규칙

### Naming
- Classes/Widgets: `PascalCase`
- Files: `snake_case.dart`
- Functions/Variables: `camelCase`
- Constants: `camelCase` (Dart 컨벤션)

### Flutter 규칙
- 모든 위젯은 `const` 생성자 사용 가능하면 사용
- Provider는 `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용
- 에러 처리: try/catch + 사용자에게 SnackBar로 알림

### Dart 주석
- 공개 API에는 `///` dartdoc 주석 (한국어)
- 복잡한 로직에만 인라인 주석

---

## 7. 보안 및 개인정보

### API 키 관리
- 앱: `.env` 파일 (gitignore)
- Edge Functions: `npx supabase secrets set KEY=value`

### 개인정보 변경 시 필수 확인
배포 시 개인정보 수집 항목이 변경되면:
1. 변경 사항 요약
2. 개인정보 처리방침 수정 필요 여부 확인
3. 사용자에게 알림

---

## 8. 작업 투명성 (중요 결정 시)

복잡한 기능 구현이나 아키텍처 결정 시에만 적용:

```
## 📌 작업 계획
**목표**: [...]
**접근 방법**: [...]
**기술적 선택 이유**: [...]

## ✅ 완료 요약
**변경 파일**: [...]
**주요 결정**: [...]
```

단순 수정, 버그 픽스에는 불필요.

---

## 9. Git 규칙

### Commit Message
- `feat:` 새 기능
- `fix:` 버그 수정
- `refactor:` 리팩토링
- `chore:` 설정, 의존성 등

### Branch (필요시)
- `feature/<name>`
- `fix/<name>`

---

## 10. 자주 사용하는 명령어

```bash
# 의존성 설치
flutter pub get

# 빌드 러너 (mockito 등)
dart run build_runner build

# 테스트
flutter test

# iOS 빌드
flutter build ipa --release

# Edge Function 로그 확인
npx supabase functions logs <function-name>
```

---

## 11. 알려진 제약사항

- Google Vision API: 결제 활성화 필요 (403 에러 시 확인)
- Aladin API: TTBKey 필요, 일일 호출 제한 있음
- iOS 최소 버전: 13.0
- Android minSdk: 21

---

## 12. 테스트 전략

### 테스트 유형별 위치
| 유형 | 위치 | 목적 |
|------|------|------|
| Unit Test | `test/` | 로직 검증 (services, providers) |
| Widget Test | `test/widgets/` | UI 컴포넌트 검증 |
| Integration Test | `integration_test/` | E2E 사용자 흐름 |

### 새 기능 추가 시 필수 테스트
- [ ] 관련 Provider에 대한 unit test
- [ ] 주요 화면에 대한 widget test
- [ ] 기존 테스트 통과 확인: `flutter test`

### 회귀 테스트 (Regression)
기존 기능 영향 여부 확인 - 아래 핵심 흐름이 정상 동작하는지 검증:
- 책 추가/수정/삭제 흐름
- 노트 OCR → 저장 흐름
- 로그인/로그아웃 흐름
- 카테고리 관리 흐름

---

## 13. 릴리즈 전 체크리스트

### 코드 품질
- [ ] `print()` / `debugPrint()` 문 제거 또는 `kDebugMode` 조건 추가
- [ ] 불필요한 주석 정리
- [ ] `flutter analyze` 경고 0개 확인

### 테스트
- [ ] `flutter test` 전체 통과
- [ ] TestFlight(iOS) / 내부 테스트(Android)에서 수동 테스트
- [ ] 주요 사용자 흐름 검증 (책 추가 → 노트 작성 → OCR)

### 버전 관리
- [ ] `pubspec.yaml` 버전 업데이트 (`version: x.y.z+buildNumber`)
- [ ] 변경사항 문서화 (릴리즈 노트)

### 배포 후
- [ ] 에러 모니터링 대시보드 확인
- [ ] 단계적 출시 (Staged Rollout) 권장 - 10% → 50% → 100%

---

## 14. CI/CD (Xcode Cloud)

### 워크플로우 설정
- App Store Connect → 앱 선택 → Xcode Cloud
- dev/prod 앱 각각 별도 워크플로우 필요
- TestFlight 배포: 첫 빌드 완료 후 Post-Actions에서 활성화

### ci_post_clone.sh 필수 단계
스크립트 수정 시 아래 순서 유지:
```bash
1. Flutter SDK 설치 (git clone)
2. flutter pub get
3. flutter precache --ios
4. pod install --repo-update
5. flutter build ios --release --no-codesign  # ← 필수! 누락 시 빌드 실패
```

### 빌드 실패 시 확인
| 에러 | 원인 | 해결 |
|------|------|------|
| `PhaseScriptExecution failed` | ci_post_clone.sh에서 flutter build 누락 | 스크립트에 flutter build ios 추가 |
| `exit code 65` | Scheme 또는 빌드 설정 문제 | Xcode에서 scheme 확인 |
| `FLUTTER_ROOT not set` | Flutter 경로 문제 | PATH 설정 확인 |

### Flavor별 빌드 명령어
```bash
# Dev 빌드
flutter build ipa --flavor dev --release

# Prod 빌드
flutter build ipa --flavor prod --release
```

---

## 15. 에러 모니터링

### 로깅 규칙
```dart
// 개발 환경에서만 출력
if (kDebugMode) {
  print('Debug: $message');
}

// 또는 조건부 로깅
debugPrint('Info: $message');  // release 빌드에서 자동 제거됨
```

### 프로덕션 에러 추적
- 크래시 발생 시 즉시 확인할 수 있도록 모니터링 도구 연동 권장
- Firebase Crashlytics 또는 Sentry 등

---

## 16. 변경사항 검증 방법

### 코드 변경 후 필수 실행
```bash
flutter analyze          # 정적 분석 - 경고/에러 확인
flutter test             # 테스트 실행
flutter build ios --flavor dev --release  # 빌드 확인 (선택)
```

### Provider 수정 시
- 해당 Provider를 사용하는 모든 화면에서 수동 테스트
- `ref.watch()` / `ref.read()` 사용처 확인

### Service 수정 시
- 관련 Provider 동작 확인
- API 호출 결과 검증

### Edge Function 수정 시
```bash
# 로컬 테스트
npx supabase functions serve <function-name>

# 배포 (반드시 --no-verify-jwt 플래그)
npx supabase functions deploy <function-name> --no-verify-jwt
```

### 모델 수정 시
- `fromJson()` / `toJson()` 호환성 확인
- DB 스키마 변경 필요 여부 확인
- 관련 서비스/프로바이더 모두 테스트
