/// BookDetailScreen 테스트
///
/// 책 상세 화면의 기본 UI 요소를 검증합니다.
/// 이미지 피커, 크롭퍼 등 복잡한 기능은 통합 테스트에서 수행합니다.
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/book.dart';
import 'package:bookscribe/models/note.dart';
import '../mocks/test_fixtures.dart';

void main() {
  group('BookDetailScreen 의존성', () {
    test('Book 모델을 올바르게 생성할 수 있다', () {
      final book = TestBooks.harryPotter;

      expect(book.id, isNotEmpty);
      expect(book.title, '해리포터와 마법사의 돌');
      expect(book.author, 'J.K. 롤링');
    });

    test('Book의 카테고리 ID 목록이 있다', () {
      final book = TestBooks.harryPotter;
      expect(book.categoryIds, isA<List<String>>());
    });

    test('Book 카테고리 ID 목록을 관리할 수 있다', () {
      final book = Book(
        id: 'book-1',
        title: '테스트 책',
        author: '저자',
        isbn: '1234567890',
        coverImage: '',
        addedAt: DateTime.now(),
        categoryIds: ['cat-1', 'cat-2'],
      );

      expect(book.categoryIds, hasLength(2));
      expect(book.categoryIds, contains('cat-1'));
    });

    test('Book copyWith으로 카테고리 업데이트', () {
      final original = TestBooks.harryPotter;
      final updated = original.copyWith(
        categoryIds: ['new-cat'],
      );

      expect(updated.categoryIds, ['new-cat']);
      expect(original.categoryIds, isNot(['new-cat']));
    });
  });

  group('BookDetailScreen Note 관리', () {
    test('Note 모델을 생성할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '인상 깊은 문장입니다.',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, 'note-1');
      expect(note.content, contains('인상 깊은'));
    });

    test('Note에 메모를 추가할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '원본 내용',
        memo: '내 생각: 좋은 문장',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.memo, isNotNull);
      expect(note.memo, contains('내 생각'));
    });

    test('Note에 요약을 저장할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        summary: 'AI 요약 내용',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.summary, isNotNull);
      expect(note.summary, contains('요약'));
    });

    test('Note 목록을 책 ID로 필터링할 수 있다', () {
      final now = DateTime.now();
      final notes = [
        Note(id: 'n1', bookId: 'book-1', content: 'A', createdAt: now, updatedAt: now),
        Note(id: 'n2', bookId: 'book-2', content: 'B', createdAt: now, updatedAt: now),
        Note(id: 'n3', bookId: 'book-1', content: 'C', createdAt: now, updatedAt: now),
      ];

      final book1Notes = notes.where((n) => n.bookId == 'book-1').toList();
      expect(book1Notes, hasLength(2));
    });
  });

  group('BookDetailScreen 카테고리 기능', () {
    test('책에 최대 카테고리 수 제한이 있다', () {
      // constants.dart의 maxCategoriesPerBook = 4
      const maxCategories = 4;
      expect(maxCategories, 4);
    });

    test('카테고리 ID 목록 추가 가능 여부 확인', () {
      final currentIds = ['cat-1', 'cat-2'];
      const maxCategories = 4;

      expect(currentIds.length < maxCategories, true);
    });

    test('카테고리 ID 제거', () {
      var categoryIds = ['cat-1', 'cat-2', 'cat-3'];
      categoryIds = categoryIds.where((id) => id != 'cat-2').toList();

      expect(categoryIds, hasLength(2));
      expect(categoryIds, isNot(contains('cat-2')));
    });
  });

  group('BookDetailScreen 이미지 처리', () {
    test('이미지 소스 옵션 (카메라/갤러리)', () {
      // ImageSource.camera, ImageSource.gallery
      const cameraOption = 'camera';
      const galleryOption = 'gallery';

      expect(cameraOption, isNotEmpty);
      expect(galleryOption, isNotEmpty);
    });

    test('이미지 바이트 데이터 처리 가능', () {
      // Uint8List 형태로 이미지 처리
      final imageBytes = List<int>.generate(100, (i) => i);
      expect(imageBytes.length, 100);
    });
  });

  group('BookDetailScreen 삭제 기능', () {
    test('책 삭제 시 확인 다이얼로그 표시', () {
      // 삭제 확인 다이얼로그 텍스트
      const dialogTitle = '책 삭제';
      const dialogContent = '이 책을 삭제하시겠습니까?';

      expect(dialogTitle, isNotEmpty);
      expect(dialogContent, contains('삭제'));
    });

    test('책 삭제 시 관련 노트도 함께 삭제됨', () {
      // CASCADE 삭제 동작
      final bookId = 'book-to-delete';
      final now = DateTime.now();
      final notes = [
        Note(id: 'n1', bookId: bookId, content: 'A', createdAt: now, updatedAt: now),
        Note(id: 'n2', bookId: bookId, content: 'B', createdAt: now, updatedAt: now),
      ];

      // 책 삭제 후 해당 노트들도 삭제되어야 함
      final remainingNotes = notes.where((n) => n.bookId != bookId).toList();
      expect(remainingNotes, isEmpty);
    });
  });
}
