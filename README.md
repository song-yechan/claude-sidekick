# BookScribe

> 책 속 문장을 촬영하고 나만의 독서 노트를 만드는 앱

독서하며 마음에 드는 문장을 사진으로 찍으면 OCR로 텍스트를 추출하고, 이미지 크롭과 편집 기능으로 깔끔하게 정리할 수 있는 독서 기록 앱입니다.

## 주요 기능

### 책 관리
- **알라딘 API 연동**: 제목, 저자, ISBN으로 책 검색
- **서재 관리**: 등록한 책을 카테고리별로 정리
- **책 정보 자동 수집**: 표지 이미지, 출판사, 페이지 수 등

### 문장 수집 (OCR)
- **사진 촬영/갤러리**: 책 페이지를 촬영하거나 이미지 선택
- **이미지 크롭**: 원하는 영역만 선택하여 텍스트 추출
- **Google Vision OCR**: 한글/영문 텍스트 정확하게 인식
- **줄바꿈 자동 정리**: 불필요한 줄바꿈 제거로 깔끔한 텍스트

### 독서 활동 추적
- **활동 캘린더**: GitHub 스타일 잔디 히트맵으로 독서 기록 시각화
- **연도별 조회**: 과거 독서 활동 확인
- **통계**: 등록한 책 수, 수집한 문장 수 실시간 확인

### 카테고리 분류
- **사용자 정의 카테고리**: 소설, 에세이, 자기계발 등 자유롭게 생성
- **색상 자동 할당**: 각 카테고리별 고유 색상
- **책 다중 카테고리**: 한 책을 여러 카테고리에 등록 가능

## 기술 스택

### 앱 (Flutter)
| 구분 | 기술 |
|------|------|
| Framework | Flutter 3.10+ / Dart |
| 상태 관리 | Riverpod |
| 라우팅 | go_router |
| 이미지 처리 | image_picker, image_cropper |

### 백엔드 (Supabase)
| 구분 | 기술 |
|------|------|
| Database | PostgreSQL |
| Authentication | Supabase Auth (이메일) |
| Storage | Supabase Storage (이미지) |
| Edge Functions | Deno (OCR, 책 검색) |

### 외부 API
| 구분 | 용도 |
|------|------|
| Google Cloud Vision | OCR 텍스트 추출 |
| 알라딘 API | 도서 검색 |

## 프로젝트 구조

```
book-note-scribe/
├── app/                      # Flutter 앱
│   ├── lib/
│   │   ├── core/             # 상수, 테마, Supabase 클라이언트
│   │   ├── models/           # Book, Note, Category 데이터 모델
│   │   ├── providers/        # Riverpod 상태 관리
│   │   ├── services/         # API 호출 서비스
│   │   ├── screens/          # 화면 위젯
│   │   ├── widgets/          # 재사용 위젯
│   │   └── router/           # go_router 설정
│   └── test/                 # 단위/위젯 테스트
├── supabase/
│   ├── functions/            # Edge Functions
│   │   ├── ocr-image/        # Google Vision OCR
│   │   └── book-search/      # 알라딘 API 연동
│   └── migrations/           # DB 마이그레이션
└── web/                      # 웹 버전 (React, 레거시)
```

## 시작하기

### 요구 사항
- Flutter SDK 3.10+
- Dart SDK 3.0+
- Xcode (iOS 빌드)
- Android Studio (Android 빌드)

### 설치

```bash
# 저장소 클론
git clone https://github.com/song-yechan/book-note-scribe.git
cd book-note-scribe/app

# 의존성 설치
flutter pub get

# 환경 변수 설정
cp .env.example .env
# .env 파일에 SUPABASE_URL, SUPABASE_ANON_KEY 입력
```

### 실행

```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 디버그 모드
flutter run --debug
```

### 빌드

```bash
# iOS (TestFlight)
flutter build ipa --release

# Android (APK)
flutter build apk --release

# Android (App Bundle)
flutter build appbundle --release
```

## 환경 변수

### 앱 (.env)
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Edge Functions (Supabase Secrets)
```bash
npx supabase secrets set GOOGLE_VISION_API_KEY=your-key
npx supabase secrets set ALADIN_TTB_KEY=your-key
```

## 테스트

```bash
# 전체 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/models/book_test.dart

# 커버리지 포함
flutter test --coverage
```

## 스크린샷

| 홈 (활동 캘린더) | 서재 | 책 상세 |
|:---:|:---:|:---:|
| 잔디 히트맵으로 독서 활동 시각화 | 카테고리별 책 관리 | OCR로 문장 수집 |

| 검색 | 문장 수집 | 노트 상세 |
|:---:|:---:|:---:|
| 알라딘 API 도서 검색 | 이미지 크롭 후 텍스트 추출 | 원문 확인 및 메모 |

## 주요 변경 사항

### v1.0.0
- 기본 기능 구현 (책 관리, 문장 수집, 카테고리)
- Google Vision OCR 연동
- 알라딘 API 도서 검색
- 활동 캘린더 (GitHub 스타일 잔디)
- 이미지 크롭 기능 추가
- OCR 텍스트 줄바꿈 자동 정리
- 백그라운드 복귀 시 안정성 개선

## 라이선스

MIT License

## 관련 문서

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Supabase 문서](https://supabase.com/docs)
- [Riverpod 문서](https://riverpod.dev/)
- [go_router 문서](https://pub.dev/packages/go_router)
