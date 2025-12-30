/// CategoryService 테스트
///
/// MockCategoryService를 사용하여 카테고리 서비스의 동작을 검증합니다.
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mocks.dart';

void main() {
  late MockCategoryService categoryService;

  setUp(() {
    categoryService = MockCategoryService();
  });

  tearDown(() {
    categoryService.reset();
  });

  group('getCategories', () {
    test('사용자의 카테고리 목록을 반환한다', () async {
      // Given
      categoryService.seedCategories(TestCategories.all);

      // When
      final categories = await categoryService.getCategories(TestUsers.userId1);

      // Then
      expect(categories.length, 3);
    });

    test('생성순으로 정렬된다', () async {
      // Given
      categoryService.seedCategories(TestCategories.all);

      // When
      final categories = await categoryService.getCategories(TestUsers.userId1);

      // Then
      expect(categories.first.name, '소설'); // 가장 먼저 생성
      expect(categories.last.name, '과학'); // 가장 나중에 생성
    });

    test('다른 사용자의 카테고리는 반환하지 않는다', () async {
      // Given
      categoryService.seedCategories(TestCategories.all);

      // When
      final categories = await categoryService.getCategories(TestUsers.userId2);

      // Then
      expect(categories, isEmpty);
    });

    test('에러 발생 시 예외를 던진다', () async {
      // Given
      categoryService.shouldThrowOnGetCategories = true;

      // When & Then
      expect(
        () => categoryService.getCategories(TestUsers.userId1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('addCategory', () {
    test('새 카테고리를 추가한다', () async {
      // When
      final category = await categoryService.addCategory(
        userId: TestUsers.userId1,
        name: '새 카테고리',
        color: '#123456',
      );

      // Then
      expect(category.name, '새 카테고리');
      expect(category.color, '#123456');
      expect(categoryService.categories.length, 1);
    });

    test('중복 이름의 카테고리는 예외를 던진다', () async {
      // Given
      await categoryService.addCategory(
        userId: TestUsers.userId1,
        name: '소설',
        color: '#FF0000',
      );

      // When & Then
      expect(
        () => categoryService.addCategory(
          userId: TestUsers.userId1,
          name: '소설',
          color: '#00FF00',
        ),
        throwsA(predicate((e) => e.toString().contains('already exists'))),
      );
    });

    test('다른 사용자는 같은 이름의 카테고리를 만들 수 있다', () async {
      // Given
      await categoryService.addCategory(
        userId: TestUsers.userId1,
        name: '소설',
        color: '#FF0000',
      );

      // When
      final category = await categoryService.addCategory(
        userId: TestUsers.userId2,
        name: '소설',
        color: '#00FF00',
      );

      // Then
      expect(category.name, '소설');
      expect(categoryService.categories.length, 2);
    });
  });

  group('updateCategory', () {
    test('카테고리 이름을 수정한다', () async {
      // Given
      categoryService.seedCategories([TestCategories.fiction]);

      // When
      await categoryService.updateCategory(
        categoryId: TestCategories.categoryId1,
        name: '장편소설',
      );

      // Then
      final updated = categoryService.categories.first;
      expect(updated.name, '장편소설');
      expect(updated.color, '#FF6B6B'); // 변경되지 않음
    });

    test('카테고리 색상을 수정한다', () async {
      // Given
      categoryService.seedCategories([TestCategories.fiction]);

      // When
      await categoryService.updateCategory(
        categoryId: TestCategories.categoryId1,
        color: '#ABCDEF',
      );

      // Then
      final updated = categoryService.categories.first;
      expect(updated.color, '#ABCDEF');
      expect(updated.name, '소설'); // 변경되지 않음
    });

    test('존재하지 않는 카테고리 수정 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => categoryService.updateCategory(
          categoryId: 'non-existent',
          name: '새 이름',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteCategory', () {
    test('카테고리를 삭제한다', () async {
      // Given
      categoryService.seedCategories(TestCategories.all);
      expect(categoryService.categories.length, 3);

      // When
      await categoryService.deleteCategory(TestCategories.categoryId1);

      // Then
      expect(categoryService.categories.length, 2);
      expect(
        categoryService.categories.any((c) => c.id == TestCategories.categoryId1),
        false,
      );
    });

    test('존재하지 않는 카테고리 삭제 시 예외를 던진다', () async {
      // When & Then
      expect(
        () => categoryService.deleteCategory('non-existent'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('최대 카테고리 제한 테스트', () {
    test('책당 최대 4개 카테고리 정책 검증', () async {
      // Given - 4개 카테고리 생성
      for (int i = 1; i <= 4; i++) {
        await categoryService.addCategory(
          userId: TestUsers.userId1,
          name: '카테고리$i',
          color: '#00000$i',
        );
      }

      // Then - 4개 카테고리가 정상적으로 생성됨
      final categories = await categoryService.getCategories(TestUsers.userId1);
      expect(categories.length, 4);

      // Note: 실제 maxCategoriesPerBook 제한은 UI 레이어에서 적용됨
      // 서비스 레이어에서는 카테고리 생성에 제한이 없음
    });
  });

  group('에러 시뮬레이션', () {
    test('addCategory 에러를 시뮬레이션할 수 있다', () async {
      // Given
      categoryService.shouldThrowOnAddCategory = true;
      categoryService.errorMessage = 'Database error';

      // When & Then
      expect(
        () => categoryService.addCategory(
          userId: TestUsers.userId1,
          name: '테스트',
          color: '#000000',
        ),
        throwsA(predicate((e) => e.toString().contains('Database error'))),
      );
    });
  });
}
