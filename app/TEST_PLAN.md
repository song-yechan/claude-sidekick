# BookScan Flutter App Test Plan

## 테스트 전략

### 테스트 레벨
1. **Unit Tests** - 개별 함수/클래스 테스트
2. **Widget Tests** - UI 컴포넌트 테스트
3. **Integration Tests** - 전체 흐름 테스트

---

## 1. Unit Tests

### Models (`test/models/`)

#### `book_test.dart`
```dart
// - Book.fromJson() 변환 테스트
// - Book.toJson() 변환 테스트
// - categoryIds 빈 배열 처리
// - nullable 필드 처리
```

#### `category_test.dart`
```dart
// - Category.fromJson() 변환 테스트
// - 색상 코드 유효성 검증
```

#### `note_test.dart`
```dart
// - Note.fromJson() 변환 테스트
// - tags 빈 배열 처리
// - createdAt/updatedAt 파싱
```

### Services (`test/services/`)

#### `auth_service_test.dart`
```dart
// - signUp 성공/실패 케이스
// - signIn 성공/실패 케이스
// - signOut 동작 확인
// - 세션 복구 테스트
```

#### `book_service_test.dart`
```dart
// - getBooks() 목록 조회
// - addBook() 책 추가
// - updateBook() 책 수정
// - deleteBook() 책 삭제
// - 인증 없이 호출 시 에러 처리
```

#### `category_service_test.dart`
```dart
// - getCategories() 목록 조회
// - addCategory() 카테고리 추가 (색상 자동 할당)
// - updateCategory() 이름 수정
// - deleteCategory() 삭제
```

#### `note_service_test.dart`
```dart
// - getNotesByBook() 책별 노트 조회
// - addNote() 노트 추가
// - updateNote() 노트 수정
// - deleteNote() 노트 삭제
```

#### `ocr_service_test.dart`
```dart
// - extractText() Edge Function 호출
// - summarizeText() Edge Function 호출
// - 에러 응답 처리
```

### Providers (`test/providers/`)

#### `auth_provider_test.dart`
```dart
// - 초기 상태 (로그아웃)
// - 로그인 후 상태 변경
// - 로그아웃 후 상태 초기화
// - 자동 로그인 (세션 복구)
```

#### `book_provider_test.dart`
```dart
// - 책 목록 로딩 상태
// - 책 추가 후 목록 갱신
// - 책 삭제 후 목록 갱신
// - getBookById() 단일 책 조회
// - getBooksByCategory() 카테고리별 필터
```

---

## 2. Widget Tests

### Screens (`test/screens/`)

#### `auth_screen_test.dart`
```dart
// - 로그인 폼 렌더링
// - 회원가입 폼 전환
// - 이메일 유효성 검사 표시
// - 비밀번호 유효성 검사 표시
// - 로그인 버튼 탭 시 로딩 표시
// - 에러 메시지 표시
```

#### `home_screen_test.dart`
```dart
// - 활동 캘린더 렌더링
// - 연도 선택 동작
// - 통계 (책 수, 노트 수) 표시
// - 하단 네비게이션 표시
```

#### `search_screen_test.dart`
```dart
// - 검색창 렌더링
// - 검색어 입력 후 결과 표시
// - 검색 결과 없음 표시
// - 책 선택 시 상세 화면 이동
// - 책 추가 버튼 동작
```

#### `library_screen_test.dart`
```dart
// - 책 목록 렌더링
// - 빈 서재 메시지 표시
// - 책 카드 탭 시 상세 화면 이동
// - 스크롤 동작
```

#### `book_detail_screen_test.dart`
```dart
// - 책 정보 표시
// - 노트 목록 표시
// - 카메라 버튼 표시
// - 노트 추가 플로우
// - 책 삭제 확인 다이얼로그
```

### Widgets (`test/widgets/`)

#### `book_card_test.dart`
```dart
// - 책 표지 이미지 표시
// - 제목/저자 표시
// - 표지 없을 때 플레이스홀더
// - 탭 콜백 동작
```

#### `category_chip_test.dart`
```dart
// - 카테고리 이름 표시
// - 색상 적용 확인
// - 선택 상태 스타일
```

#### `bottom_nav_test.dart`
```dart
// - 4개 탭 렌더링 (홈, 검색, 서재, 카테고리)
// - 현재 탭 하이라이트
// - 탭 전환 동작
```

---

## 3. Integration Tests

### `test_driver/` 또는 `integration_test/`

#### `auth_flow_test.dart`
```dart
// 1. 앱 시작 → 로그인 화면
// 2. 회원가입 진행
// 3. 로그인 성공 → 홈 화면 이동
// 4. 로그아웃 → 로그인 화면 복귀
```

#### `book_flow_test.dart`
```dart
// 1. 로그인 상태에서 시작
// 2. 검색 탭 → 책 검색
// 3. 책 선택 → 서재에 추가
// 4. 서재 탭 → 추가된 책 확인
// 5. 책 상세 → 책 삭제
// 6. 서재에서 책 사라짐 확인
```

#### `note_flow_test.dart`
```dart
// 1. 책 상세 화면 진입
// 2. 카메라로 사진 촬영 (모킹)
// 3. OCR 결과 확인
// 4. AI 요약 생성
// 5. 노트 저장
// 6. 노트 목록에서 확인
// 7. 노트 삭제
```

#### `category_flow_test.dart`
```dart
// 1. 카테고리 탭 진입
// 2. 새 카테고리 추가
// 3. 카테고리에 책 할당
// 4. 카테고리 상세 → 책 목록 확인
// 5. 카테고리 삭제
```

---

## 4. 테스트 설정

### `test/test_helper.dart`
```dart
// Supabase 모킹 설정
// 공통 테스트 유틸리티
// 테스트용 데이터 팩토리
```

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0          # 모킹
  network_image_mock: ^2.0.0 # 네트워크 이미지 모킹
  integration_test:
    sdk: flutter
```

---

## 5. 테스트 실행

```bash
# Unit + Widget 테스트
flutter test

# 특정 파일 테스트
flutter test test/models/book_test.dart

# 커버리지 리포트
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Integration 테스트 (에뮬레이터 필요)
flutter test integration_test/
```

---

## 6. CI/CD 연동 (GitHub Actions)

```yaml
# .github/workflows/test.yml
name: Flutter Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
        working-directory: ./app
      - run: flutter test
        working-directory: ./app
```

---

## 7. 테스트 우선순위

### P0 (필수)
- [ ] AuthService 테스트
- [ ] Book/Category/Note 모델 테스트
- [ ] AuthScreen 위젯 테스트
- [ ] 로그인 플로우 통합 테스트

### P1 (중요)
- [ ] BookService CRUD 테스트
- [ ] NoteService CRUD 테스트
- [ ] HomeScreen 위젯 테스트
- [ ] 책 추가 플로우 통합 테스트

### P2 (보통)
- [ ] CategoryService 테스트
- [ ] OCRService 테스트
- [ ] 나머지 위젯 테스트
- [ ] 노트 플로우 통합 테스트
