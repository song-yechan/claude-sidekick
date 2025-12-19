# Bookscribe

책 속 문장을 촬영하고 AI로 요약하여 나만의 독서 기록을 만드는 앱

## 주요 기능

- **문장 수집**: 카메라로 책 속 문장을 촬영하여 OCR로 텍스트 추출
- **AI 요약**: 추출된 문장을 AI가 자동으로 요약
- **독서 기록**: 책별로 수집한 문장과 메모를 관리
- **카테고리 관리**: 책을 카테고리별로 분류
- **독서 활동 캘린더**: GitHub 스타일의 활동 히트맵으로 독서 습관 시각화
- **다크 모드**: 시스템 설정 연동 및 수동 전환 지원

## 기술 스택

- **Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod
- **Routing**: go_router
- **Backend**: Supabase (Auth, Database, Storage)
- **Design System**: Material Design 3

## 프로젝트 구조

```
lib/
├── core/
│   └── theme.dart          # M3 디자인 시스템 (라이트/다크 테마)
├── models/
│   ├── book.dart
│   ├── note.dart
│   └── category.dart
├── providers/
│   ├── auth_provider.dart
│   ├── book_provider.dart
│   ├── note_provider.dart
│   ├── category_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── auth/
│   ├── home/
│   ├── library/
│   ├── book/
│   ├── note/
│   ├── categories/
│   ├── search/
│   └── settings/
├── widgets/
│   ├── book/
│   ├── note/
│   ├── category/
│   └── common/
├── services/
│   └── ocr_service.dart
├── router/
│   └── app_router.dart
└── main.dart
```

## 시작하기

### 요구사항

- Flutter 3.10 이상
- Dart 3.0 이상
- iOS 12.0+ / Android API 21+

### 설치

```bash
# 의존성 설치
flutter pub get

# 환경 변수 설정 (.env 파일 생성)
cp .env.example .env
# Supabase URL과 Anon Key 설정

# 실행
flutter run
```

### 테스트

```bash
flutter test
```

## 디자인 시스템

Material Design 3 기반의 커스텀 디자인 시스템 사용:

- **색상**: Primary (인디고 블루), Secondary, Tertiary, Surface variants
- **Shape**: extraSmall(4) ~ extraLarge(28) + full(pill)
- **Spacing**: 8pt grid 기반 (xs:4 ~ xxxl:48)
- **다크 모드**: 완전한 다크 테마 지원

## 라이선스

Private - All rights reserved
