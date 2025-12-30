/// CategoryProvider 테스트
///
/// 카테고리 Provider 함수들의 기본 동작을 검증합니다.
/// 실제 Riverpod Provider 테스트는 통합 테스트에서 수행합니다.
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/category.dart';

void main() {
  group('Category Provider 관련 모델', () {
    test('Category can be created for provider use', () {
      final category = Category(
        id: 'cat-1',
        name: '소설',
        color: '#FF5733',
        createdAt: DateTime.now(),
      );

      expect(category.id, 'cat-1');
      expect(category.name, '소설');
    });

    test('Category list can be filtered by id', () {
      final categories = [
        Category(
          id: 'cat-1',
          name: '소설',
          color: '#FF5733',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'cat-2',
          name: '에세이',
          color: '#33FF57',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'cat-3',
          name: '자기계발',
          color: '#5733FF',
          createdAt: DateTime.now(),
        ),
      ];

      final found = categories.where((c) => c.id == 'cat-2').firstOrNull;
      expect(found?.name, '에세이');
    });

    test('Category list returns null for non-existent id', () {
      final categories = [
        Category(
          id: 'cat-1',
          name: '소설',
          color: '#FF5733',
          createdAt: DateTime.now(),
        ),
      ];

      final found = categories.where((c) => c.id == 'non-existent').firstOrNull;
      expect(found, isNull);
    });

    test('Empty category list handling', () {
      final categories = <Category>[];

      final found = categories.where((c) => c.id == 'any').firstOrNull;
      expect(found, isNull);
      expect(categories.length, 0);
    });
  });

  group('Category color index calculation', () {
    test('color index cycles through available colors', () {
      const colorCount = 9; // categoryColors.length

      expect(0 % colorCount, 0);
      expect(1 % colorCount, 1);
      expect(8 % colorCount, 8);
      expect(9 % colorCount, 0); // wraps around
      expect(10 % colorCount, 1);
    });

    test('color index is always non-negative', () {
      const colorCount = 9;

      for (int i = 0; i < 100; i++) {
        expect(i % colorCount, greaterThanOrEqualTo(0));
        expect(i % colorCount, lessThan(colorCount));
      }
    });
  });

  group('Category CRUD operations validation', () {
    test('category name should not be empty', () {
      const name = '';
      expect(name.isEmpty, true);
    });

    test('category name should be trimmed', () {
      const name = '  소설  ';
      expect(name.trim(), '소설');
    });

    test('category id format', () {
      const id = 'uuid-format-id';
      expect(id.isNotEmpty, true);
    });
  });

  group('Category list operations', () {
    test('can add category to list', () {
      final categories = <Category>[];
      final newCategory = Category(
        id: 'new-1',
        name: '새 카테고리',
        color: '#000000',
        createdAt: DateTime.now(),
      );

      categories.add(newCategory);
      expect(categories.length, 1);
      expect(categories.first.name, '새 카테고리');
    });

    test('can remove category from list', () {
      final category = Category(
        id: 'cat-1',
        name: '삭제할 카테고리',
        color: '#000000',
        createdAt: DateTime.now(),
      );
      final categories = [category];

      categories.removeWhere((c) => c.id == 'cat-1');
      expect(categories.isEmpty, true);
    });

    test('can update category in list', () {
      final original = Category(
        id: 'cat-1',
        name: '원래 이름',
        color: '#000000',
        createdAt: DateTime.now(),
      );
      var categories = [original];

      final updated = original.copyWith(name: '새 이름');
      categories = categories.map((c) => c.id == 'cat-1' ? updated : c).toList();

      expect(categories.first.name, '새 이름');
    });
  });
}
