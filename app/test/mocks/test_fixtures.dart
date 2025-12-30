/// 테스트용 샘플 데이터 (Fixtures)
///
/// 테스트에서 사용할 샘플 데이터를 중앙에서 관리합니다.
/// 일관된 테스트 데이터를 제공하여 테스트 가독성을 높입니다.
library;

import 'package:bookscribe/models/book.dart';
import 'package:bookscribe/models/note.dart';
import 'package:bookscribe/models/category.dart';

/// 테스트용 사용자 ID
class TestUsers {
  static const String userId1 = 'test-user-id-1';
  static const String userId2 = 'test-user-id-2';
  static const String email1 = 'test1@example.com';
  static const String email2 = 'test2@example.com';
  static const String password = 'testPassword123!';
  static const String weakPassword = '123';
}

/// 테스트용 카테고리 데이터
class TestCategories {
  static const String categoryId1 = 'cat-id-1';
  static const String categoryId2 = 'cat-id-2';
  static const String categoryId3 = 'cat-id-3';

  static Category get fiction => Category(
        id: categoryId1,
        name: '소설',
        color: '#FF6B6B',
        createdAt: DateTime(2024, 1, 1),
      );

  static Category get selfHelp => Category(
        id: categoryId2,
        name: '자기계발',
        color: '#4ECDC4',
        createdAt: DateTime(2024, 1, 2),
      );

  static Category get science => Category(
        id: categoryId3,
        name: '과학',
        color: '#45B7D1',
        createdAt: DateTime(2024, 1, 3),
      );

  static List<Category> get all => [fiction, selfHelp, science];

  static Map<String, dynamic> get fictionJson => {
        'id': categoryId1,
        'user_id': TestUsers.userId1,
        'name': '소설',
        'color': '#FF6B6B',
        'created_at': '2024-01-01T00:00:00.000Z',
      };
}

/// 테스트용 책 데이터
class TestBooks {
  static const String bookId1 = 'book-id-1';
  static const String bookId2 = 'book-id-2';
  static const String bookId3 = 'book-id-3';

  static Book get harryPotter => Book(
        id: bookId1,
        title: '해리포터와 마법사의 돌',
        author: 'J.K. 롤링',
        isbn: '9788983920683',
        publisher: '문학수첩',
        publishDate: '2019-11-25',
        coverImage: 'https://example.com/harry-potter.jpg',
        description: '해리포터 시리즈의 첫 번째 책',
        pageCount: 336,
        addedAt: DateTime(2024, 1, 15),
        categoryIds: [TestCategories.categoryId1],
      );

  static Book get atomicHabits => Book(
        id: bookId2,
        title: '아주 작은 습관의 힘',
        author: '제임스 클리어',
        isbn: '9788996094791',
        publisher: '비즈니스북스',
        publishDate: '2019-02-26',
        coverImage: 'https://example.com/atomic-habits.jpg',
        description: '최고의 변화는 가장 작은 습관에서 시작된다',
        pageCount: 380,
        addedAt: DateTime(2024, 2, 1),
        categoryIds: [TestCategories.categoryId2],
      );

  static Book get cosmos => Book(
        id: bookId3,
        title: '코스모스',
        author: '칼 세이건',
        isbn: '9788983711892',
        publisher: '사이언스북스',
        publishDate: '2006-12-20',
        coverImage: 'https://example.com/cosmos.jpg',
        description: '우주의 신비를 탐구하는 여정',
        pageCount: 584,
        addedAt: DateTime(2024, 3, 1),
        categoryIds: [TestCategories.categoryId3],
      );

  static Book get bookWithoutCategory => Book(
        id: 'book-no-cat',
        title: '카테고리 없는 책',
        author: '테스트 저자',
        addedAt: DateTime(2024, 4, 1),
        categoryIds: [],
      );

  static List<Book> get all => [harryPotter, atomicHabits, cosmos];

  static Map<String, dynamic> get harryPotterJson => {
        'id': bookId1,
        'user_id': TestUsers.userId1,
        'title': '해리포터와 마법사의 돌',
        'author': 'J.K. 롤링',
        'isbn': '9788983920683',
        'publisher': '문학수첩',
        'publish_date': '2019-11-25',
        'cover_image': 'https://example.com/harry-potter.jpg',
        'description': '해리포터 시리즈의 첫 번째 책',
        'page_count': 336,
        'added_at': '2024-01-15T00:00:00.000Z',
        'book_categories': [
          {'category_id': TestCategories.categoryId1}
        ],
      };

  static Map<String, dynamic> get harryPotterJsonWithoutCategories => {
        'id': bookId1,
        'user_id': TestUsers.userId1,
        'title': '해리포터와 마법사의 돌',
        'author': 'J.K. 롤링',
        'isbn': '9788983920683',
        'publisher': '문학수첩',
        'publish_date': '2019-11-25',
        'cover_image': 'https://example.com/harry-potter.jpg',
        'description': '해리포터 시리즈의 첫 번째 책',
        'page_count': 336,
        'added_at': '2024-01-15T00:00:00.000Z',
      };
}

/// 테스트용 노트 데이터
class TestNotes {
  static const String noteId1 = 'note-id-1';
  static const String noteId2 = 'note-id-2';
  static const String noteId3 = 'note-id-3';

  static Note get note1 => Note(
        id: noteId1,
        bookId: TestBooks.bookId1,
        content: '마법은 믿는 자에게 일어난다.',
        pageNumber: 42,
        createdAt: DateTime(2024, 1, 20),
        updatedAt: DateTime(2024, 1, 20),
      );

  static Note get note2 => Note(
        id: noteId2,
        bookId: TestBooks.bookId1,
        content: '용기란 두려움이 없는 것이 아니라, 두려움보다 더 중요한 것이 있다고 판단하는 것이다.',
        pageNumber: 156,
        createdAt: DateTime(2024, 1, 25),
        updatedAt: DateTime(2024, 1, 25),
      );

  static Note get note3 => Note(
        id: noteId3,
        bookId: TestBooks.bookId2,
        content: '1%씩 나아지면 1년 후 37배가 된다.',
        pageNumber: 23,
        createdAt: DateTime(2024, 2, 5),
        updatedAt: DateTime(2024, 2, 5),
      );

  static List<Note> get all => [note1, note2, note3];
  static List<Note> get forHarryPotter => [note1, note2];

  static Map<String, dynamic> get note1Json => {
        'id': noteId1,
        'book_id': TestBooks.bookId1,
        'user_id': TestUsers.userId1,
        'content': '마법은 믿는 자에게 일어난다.',
        'page_number': 42,
        'summary': null,
        'tags': [],
        'memo': null,
        'created_at': '2024-01-20T00:00:00.000Z',
        'updated_at': '2024-01-20T00:00:00.000Z',
      };
}

/// 테스트용 책 검색 결과 데이터
class TestBookSearchResults {
  static BookSearchResult get harryPotter => BookSearchResult(
        title: '해리포터와 마법사의 돌',
        author: 'J.K. 롤링',
        isbn: '9788983920683',
        publisher: '문학수첩',
        publishDate: '2019-11-25',
        coverImage: 'https://example.com/harry-potter.jpg',
        description: '해리포터 시리즈의 첫 번째 책',
        pageCount: 336,
      );

  static BookSearchResult get atomicHabits => BookSearchResult(
        title: '아주 작은 습관의 힘',
        author: '제임스 클리어',
        isbn: '9788996094791',
        publisher: '비즈니스북스',
        publishDate: '2019-02-26',
        coverImage: 'https://example.com/atomic-habits.jpg',
        description: '최고의 변화는 가장 작은 습관에서 시작된다',
        pageCount: 380,
      );

  static List<BookSearchResult> get searchResults =>
      [harryPotter, atomicHabits];

  static Map<String, dynamic> get harryPotterJson => {
        'title': '해리포터와 마법사의 돌',
        'author': 'J.K. 롤링',
        'isbn': '9788983920683',
        'publisher': '문학수첩',
        'pubDate': '2019-11-25',
        'cover': 'https://example.com/harry-potter.jpg',
        'description': '해리포터 시리즈의 첫 번째 책',
        'itemPage': 336,
      };

  static Map<String, dynamic> get apiResponse => {
        'items': [harryPotterJson],
        'error': null,
      };

  static Map<String, dynamic> get emptyApiResponse => {
        'items': [],
        'error': null,
      };

  static Map<String, dynamic> get errorApiResponse => {
        'items': [],
        'error': 'API key required',
      };
}

/// 테스트용 에러 메시지
class TestErrors {
  static const String invalidCredentials =
      'AuthException: Invalid login credentials';
  static const String userAlreadyExists = 'User already registered';
  static const String emailNotConfirmed = 'Email not confirmed';
  static const String invalidEmail = 'Invalid email format';
  static const String weakPassword = 'Password should be at least 6 characters';
  static const String networkError = 'Network connection failed';
  static const String rateLimitError = 'Too many requests';
  static const String unknownError = 'Some unknown error occurred';
}

/// 테스트용 날짜별 노트 카운트
class TestNoteCountsByDate {
  static Map<DateTime, int> get sampleCounts => {
        DateTime(2024, 1, 20): 1,
        DateTime(2024, 1, 25): 1,
        DateTime(2024, 2, 5): 1,
      };

  static List<Map<String, dynamic>> get apiResponse => [
        {'date': '2024-01-20', 'count': 1},
        {'date': '2024-01-25', 'count': 1},
        {'date': '2024-02-05', 'count': 1},
      ];
}
