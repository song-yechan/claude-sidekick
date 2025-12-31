<div align="center">

# BookScribe

### *Capture. Collect. Connect with Books.*

**책 속에서 발견한 영감을 나만의 라이브러리로**

[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

[Features](#features) • [Tech Stack](#tech-stack) • [Getting Started](#getting-started) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

---

## Overview

**BookScribe**는 독서 경험을 더 풍요롭게 만들어주는 앱입니다.

책을 읽다 마음에 드는 문장을 발견했을 때, 카메라로 촬영하기만 하면 됩니다.
AI가 자동으로 텍스트를 추출하고, 당신만의 디지털 독서 노트에 저장합니다.

> *"좋은 책은 당신을 변화시키고, 좋은 문장은 그 순간을 기억하게 합니다."*

---

## Features

### 📸 Smart OCR Capture
카메라로 책 페이지를 촬영하면 **ML Kit 기반의 On-Device OCR**이 즉시 텍스트를 추출합니다. 네트워크 없이도 동작하며, 복잡한 이미지는 **Cloud Vision API**로 자동 폴백되어 최적의 인식률을 보장합니다.

### 📚 Personal Library
알라딘 API 연동으로 책을 쉽게 검색하고 라이브러리에 추가하세요. 카테고리별 분류, 커스텀 태그, 독서 진행 상태 관리까지 지원합니다.

### ✨ AI-Powered Insights
수집한 문장을 AI가 분석하여 핵심 내용을 요약합니다. 나중에 다시 읽을 때 빠르게 맥락을 파악할 수 있습니다.

### 📊 Reading Activity Heatmap
GitHub 스타일의 활동 히트맵으로 당신의 독서 습관을 시각화합니다. 꾸준한 독서 루틴을 만들어가세요.

### 🌙 Beautiful Dark Mode
눈이 편안한 다크 모드를 지원합니다. 시스템 설정 연동 또는 수동 전환이 가능합니다.

---

## Tech Stack

### Frontend
| Category | Technology |
|----------|------------|
| Framework | **Flutter 3.29.2** (Dart 3.7) |
| State Management | **Riverpod** - Reactive state with compile-time safety |
| Routing | **go_router** - Declarative navigation |
| Design System | **Material Design 3** - Dynamic color, custom theming |

### Backend & Services
| Category | Technology |
|----------|------------|
| Backend | **Supabase** - Auth, PostgreSQL, Storage, Edge Functions |
| OCR (Primary) | **Google ML Kit** - On-device text recognition |
| OCR (Fallback) | **Google Cloud Vision API** - Cloud-based OCR |
| Book Search | **Aladin Open API** - Korean book metadata |

### DevOps & Quality
| Category | Technology |
|----------|------------|
| CI/CD | **GitHub Actions** - Automated testing & builds |
| Testing | **Flutter Test** + **Mockito** - Unit, Widget, Integration |
| Code Quality | **dart analyze** + **dart format** |
| Coverage | **lcov** - Coverage reporting |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ Screens  │  │ Widgets  │  │  Router  │  │  Theme System    │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────────┬─────────┘ │
└───────┼─────────────┼─────────────┼─────────────────┼───────────┘
        │             │             │                 │
┌───────▼─────────────▼─────────────▼─────────────────▼───────────┐
│                      State Management                            │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                     Riverpod Providers                       ││
│  │  Auth • Books • Notes • Categories • Theme • OCR • Search   ││
│  └─────────────────────────────────────────────────────────────┘│
└───────┬─────────────────────────────────────────────────────────┘
        │
┌───────▼─────────────────────────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │   Services   │  │    Models    │  │   Local Storage        │ │
│  │  (API calls) │  │  (Entities)  │  │   (SharedPreferences)  │ │
│  └──────┬───────┘  └──────────────┘  └────────────────────────┘ │
└─────────┼───────────────────────────────────────────────────────┘
          │
┌─────────▼───────────────────────────────────────────────────────┐
│                      External Services                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Supabase   │  │  ML Kit     │  │  Cloud Vision / Aladin  │  │
│  │  (Backend)  │  │  (On-Device)│  │  (Edge Functions)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### OCR Pipeline

```
┌──────────┐    ┌───────────────┐    ┌─────────────────┐
│  Image   │───▶│   ML Kit      │───▶│   Text Result   │
│  Input   │    │  (On-Device)  │    │   (Fast Path)   │
└──────────┘    └───────┬───────┘    └─────────────────┘
                        │
                        │ Fallback (low confidence)
                        ▼
                ┌───────────────┐    ┌─────────────────┐
                │ Cloud Vision  │───▶│   Text Result   │
                │ (Edge Func)   │    │  (High Quality) │
                └───────────────┘    └─────────────────┘
```

---

## Getting Started

### Prerequisites

- **Flutter** 3.29.2 or higher
- **Dart** 3.7 or higher
- **Xcode** 15+ (iOS development)
- **Android Studio** with Android SDK 21+ (Android development)
- **CocoaPods** (iOS dependencies)

### Environment Setup

BookScribe는 **Dev**와 **Prod** 두 가지 환경을 지원합니다.

| Environment | Bundle ID | App Name | Purpose |
|-------------|-----------|----------|---------|
| **Dev** | `com.bookscribe.app.dev` | BookScribe Dev | 개발 및 테스트 |
| **Prod** | `com.bookscribe.app` | BookScribe | 프로덕션 배포 |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/book-note-scribe.git
cd book-note-scribe/app

# 2. Install dependencies
flutter pub get

# 3. Create environment files
cp .env.example .env.dev
cp .env.example .env.prod

# 4. Configure Supabase credentials in .env files
# SUPABASE_URL=your_supabase_url
# SUPABASE_ANON_KEY=your_anon_key

# 5. Install iOS dependencies
cd ios && pod install && cd ..
```

### Running the App

```bash
# Development environment
flutter run --flavor dev -t lib/main_dev.dart

# Production environment
flutter run --flavor prod -t lib/main_prod.dart
```

### Building for Release

```bash
# iOS - Development
flutter build ipa --release --flavor dev -t lib/main_dev.dart

# iOS - Production
flutter build ipa --release --flavor prod -t lib/main_prod.dart

# Android - Development
flutter build apk --release --flavor dev -t lib/main_dev.dart

# Android - Production
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants.dart        # App constants
│   ├── env_config.dart       # Environment configuration (Dev/Prod)
│   ├── supabase_client.dart  # Supabase initialization
│   └── theme.dart            # Material 3 design system
│
├── models/
│   ├── book.dart             # Book entity
│   ├── note.dart             # Note (captured text) entity
│   └── category.dart         # Category entity
│
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   ├── book_provider.dart    # Books & search state
│   ├── note_provider.dart    # Notes CRUD state
│   ├── category_provider.dart# Categories state
│   ├── ocr_provider.dart     # OCR processing state
│   └── theme_provider.dart   # Theme preferences
│
├── services/
│   ├── ocr_service.dart      # ML Kit + Cloud Vision OCR
│   ├── book_service.dart     # Book API operations
│   ├── note_service.dart     # Note API operations
│   └── auth_service.dart     # Authentication operations
│
├── screens/
│   ├── auth/                 # Login, registration
│   ├── home/                 # Main dashboard
│   ├── library/              # Book library
│   ├── book/                 # Book detail, note capture
│   ├── note/                 # Note detail, editing
│   ├── categories/           # Category management
│   ├── search/               # Book search
│   └── settings/             # App settings
│
├── widgets/
│   ├── book/                 # Book-related widgets
│   ├── note/                 # Note-related widgets
│   ├── category/             # Category widgets
│   └── common/               # Shared components
│
├── router/
│   └── app_router.dart       # go_router configuration
│
├── main.dart                 # Default entry point (Prod)
├── main_dev.dart             # Dev environment entry
├── main_prod.dart            # Prod environment entry
└── main_common.dart          # Shared initialization logic
```

---

## Testing

```bash
# Run all unit and widget tests
flutter test

# Run with coverage report
flutter test --coverage

# Generate HTML coverage report
./scripts/coverage.sh

# Run specific test file
flutter test test/providers/book_provider_test.dart
```

### Test Structure

```
test/
├── models/          # Model unit tests
├── providers/       # Provider/Notifier tests
├── services/        # Service layer tests (with mocks)
├── widgets/         # Widget tests
├── screens/         # Screen integration tests
├── mocks/           # Shared mock objects
└── helpers/         # Test utilities
```

---

## CI/CD

### Continuous Integration

모든 PR과 main/develop 브랜치 푸시 시 자동 실행:

- **Code Formatting** - `dart format` 검증
- **Static Analysis** - `flutter analyze` 실행
- **Unit Tests** - 전체 테스트 스위트 실행
- **Coverage Report** - Codecov 업로드

### Release Workflow

`v*` 태그 푸시 시 자동 빌드:

- **Android**: APK + App Bundle (Dev/Prod flavors)
- **iOS**: Archive 생성 (수동 서명 후 업로드)
- **GitHub Release**: 자동 생성 및 아티팩트 첨부

---

## Design System

Material Design 3 기반의 커스텀 디자인 시스템:

### Color Palette
- **Primary**: Indigo Blue - 신뢰와 집중을 상징
- **Secondary**: Warm Amber - 따뜻한 독서 분위기
- **Surface**: Adaptive - 라이트/다크 모드 최적화

### Typography
- System fonts with carefully tuned weights and sizes
- Reading-optimized line heights

### Spacing System
8pt grid 기반:
- `xs`: 4pt
- `sm`: 8pt
- `md`: 16pt
- `lg`: 24pt
- `xl`: 32pt
- `xxl`: 40pt
- `xxxl`: 48pt

---

## Contributing

현재 프라이빗 프로젝트로 운영 중입니다.

내부 기여자는 다음 가이드라인을 따라주세요:

1. **Branch Naming**: `feature/<name>`, `fix/<name>`, `refactor/<name>`
2. **Commit Convention**:
   - `feat:` 새 기능
   - `fix:` 버그 수정
   - `refactor:` 리팩토링
   - `test:` 테스트 추가/수정
   - `chore:` 설정, 빌드 관련
3. **PR Requirements**: 모든 테스트 통과, 린트 에러 없음

---

## License

This project is private and proprietary. All rights reserved.

---

<div align="center">

**Built with passion for readers**

Made with Flutter

</div>
