---
name: flutter-dev
description: Flutter/Riverpod development patterns for BookScribe. Use when writing Flutter code, creating widgets, providers, or services.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# Flutter Development Skill - BookScribe

## Project Architecture

BookScribe는 **Clean Architecture + Riverpod** 패턴을 따릅니다.

```
lib/
├── core/           # 설정, 테마, 상수
├── models/         # 데이터 모델 (freezed 스타일)
├── providers/      # Riverpod StateNotifier + Provider
├── services/       # API/외부 서비스 호출
├── screens/        # 화면 위젯 (ConsumerWidget)
├── widgets/        # 재사용 위젯
└── router/         # go_router 설정
```

## Coding Patterns

### 1. Provider 패턴
```dart
// StateNotifier 사용
class BookNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final BookService _service;

  BookNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadBooks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getBooks());
  }
}

// Provider 정의
final bookNotifierProvider = StateNotifierProvider<BookNotifier, AsyncValue<List<Book>>>((ref) {
  return BookNotifier(ref.watch(bookServiceProvider));
});
```

### 2. Widget 패턴
```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bookNotifierProvider);

    return booksAsync.when(
      data: (books) => ListView.builder(...),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

### 3. Service 패턴
```dart
class BookService {
  final SupabaseClient _client;

  BookService(this._client);

  Future<List<Book>> getBooks() async {
    final response = await _client.from('books').select();
    return response.map((json) => Book.fromJson(json)).toList();
  }
}
```

### 4. Model 패턴
```dart
class Book {
  final String id;
  final String title;
  final String? author;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    this.author,
    required this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'created_at': createdAt.toIso8601String(),
  };
}
```

## Environment Configuration

Dev/Prod 환경 분리 사용:
- Entry point: `main_dev.dart` / `main_prod.dart`
- Config: `EnvConfig.dev` / `EnvConfig.prod`
- Bundle ID: `com.bookscribe.app.dev` / `com.bookscribe.app`

## Testing Patterns

```dart
// Provider 테스트
test('loads books successfully', () async {
  final container = ProviderContainer(
    overrides: [
      bookServiceProvider.overrideWithValue(MockBookService()),
    ],
  );

  await container.read(bookNotifierProvider.notifier).loadBooks();
  expect(container.read(bookNotifierProvider).value, isNotEmpty);
});

// Widget 테스트
testWidgets('displays book list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...],
      child: MaterialApp(home: BookListScreen()),
    ),
  );

  expect(find.byType(BookCard), findsWidgets);
});
```

## Key Files Reference

- Theme: `lib/core/theme.dart`
- Router: `lib/router/app_router.dart`
- Supabase: `lib/core/supabase_client.dart`
- Environment: `lib/core/env_config.dart`

## Do's and Don'ts

### Do
- Use `const` constructors wherever possible
- Use `AsyncValue` for async state
- Use `ConsumerWidget` / `ConsumerStatefulWidget`
- Follow existing naming conventions
- Add proper error handling with user feedback

### Don't
- Don't use `StatefulWidget` when `ConsumerWidget` works
- Don't call providers in `initState` - use `ref.listen` or `ref.watch`
- Don't forget to dispose resources
- Don't hardcode strings - use constants or l10n
