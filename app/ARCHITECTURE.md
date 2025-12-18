# BookScan Flutter App Architecture

## Web vs Flutter 구조 매핑

| Web (React) | Flutter | 설명 |
|-------------|---------|------|
| `src/pages/` | `lib/screens/` | 화면 UI |
| `src/hooks/` | `lib/providers/` | 상태 관리 (Riverpod) |
| `src/services/` | `lib/services/` | API 호출 |
| `src/types/` | `lib/models/` | 데이터 모델 |
| `src/contexts/` | `lib/providers/` | 전역 상태 |
| `src/components/` | `lib/widgets/` | 재사용 위젯 |
| `src/integrations/` | `lib/core/` | Supabase 설정 |

---

## Flutter 폴더 구조

```
app/lib/
├── main.dart                 # 앱 진입점, Supabase 초기화
├── core/
│   ├── supabase.dart         # Supabase 클라이언트 설정
│   ├── constants.dart        # 상수 정의
│   └── theme.dart            # 앱 테마
├── models/
│   ├── book.dart             # Book 모델
│   ├── category.dart         # Category 모델
│   └── note.dart             # Note 모델
├── providers/
│   ├── auth_provider.dart    # 인증 상태 관리
│   ├── book_provider.dart    # 책 CRUD
│   ├── category_provider.dart# 카테고리 CRUD
│   └── note_provider.dart    # 노트 CRUD
├── services/
│   ├── auth_service.dart     # 인증 API
│   ├── book_service.dart     # 책 API
│   ├── category_service.dart # 카테고리 API
│   ├── note_service.dart     # 노트 API
│   └── ocr_service.dart      # OCR Edge Function 호출
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart  # 로그인/회원가입
│   ├── home/
│   │   └── home_screen.dart  # 홈 (활동 캘린더)
│   ├── search/
│   │   └── search_screen.dart# 책 검색
│   ├── library/
│   │   └── library_screen.dart# 내 서재
│   ├── categories/
│   │   ├── categories_screen.dart
│   │   └── category_detail_screen.dart
│   ├── book/
│   │   └── book_detail_screen.dart # 책 상세 + 노트
│   └── note/
│       └── note_detail_screen.dart # 노트 상세
├── widgets/
│   ├── common/
│   │   ├── loading_indicator.dart
│   │   └── error_widget.dart
│   ├── book/
│   │   ├── book_card.dart
│   │   └── book_list.dart
│   ├── category/
│   │   └── category_chip.dart
│   ├── note/
│   │   └── note_card.dart
│   └── layout/
│       └── bottom_nav.dart   # 하단 네비게이션
└── router/
    └── app_router.dart       # GoRouter 설정
```

---

## 화면 구성 (Web 대응)

| Web Page | Flutter Screen | 경로 |
|----------|----------------|------|
| `Auth.tsx` | `AuthScreen` | `/auth` |
| `Home.tsx` | `HomeScreen` | `/` |
| `Search.tsx` | `SearchScreen` | `/search` |
| `Library.tsx` | `LibraryScreen` | `/library` |
| `Categories.tsx` | `CategoriesScreen` | `/categories` |
| `CategoryDetail.tsx` | `CategoryDetailScreen` | `/categories/:id` |
| `BookDetail.tsx` | `BookDetailScreen` | `/books/:id` |
| `NoteDetail.tsx` | `NoteDetailScreen` | `/notes/:id` |

---

## 데이터 모델

### Book
```dart
class Book {
  final String id;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final String? publishDate;
  final String? coverImage;
  final String? description;
  final List<String> categoryIds;
  final DateTime addedAt;
}
```

### Category
```dart
class Category {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
}
```

### Note
```dart
class Note {
  final String id;
  final String bookId;
  final String content;
  final String? summary;
  final int? pageNumber;
  final List<String> tags;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Supabase 테이블 (공유)

| 테이블 | 설명 |
|--------|------|
| `books` | 책 정보 |
| `categories` | 카테고리 |
| `book_categories` | 책-카테고리 매핑 |
| `notes` | 노트 |

---

## Edge Functions (공유)

| 함수 | 설명 |
|------|------|
| `book-search` | 도서 검색 API |
| `ocr-image` | 이미지 → 텍스트 추출 |
| `summarize-text` | AI 텍스트 요약 |

---

## 상태 관리 (Riverpod)

```dart
// 인증 상태
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);

// 책 목록
final booksProvider = FutureProvider<List<Book>>(...);

// 카테고리 목록
final categoriesProvider = FutureProvider<List<Category>>(...);

// 노트 목록
final notesProvider = FutureProvider<List<Note>>(...);
```
