/// Mock CategoryService
///
/// 테스트용 CategoryService 모킹 클래스입니다.
library;

import 'package:bookscribe/models/category.dart';
import 'test_fixtures.dart';

/// CategoryService 인터페이스
abstract class ICategoryService {
  Future<List<Category>> getCategories(String userId);
  Future<Category> addCategory({
    required String userId,
    required String name,
    required String color,
  });
  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? color,
  });
  Future<void> deleteCategory(String categoryId);
}

/// Mock CategoryService
class MockCategoryService implements ICategoryService {
  final List<Category> _categories = [];
  /// 카테고리 ID -> 사용자 ID 매핑 (DB에서는 user_id 컬럼으로 관리)
  final Map<String, String> _categoryOwners = {};

  bool shouldThrowOnGetCategories = false;
  bool shouldThrowOnAddCategory = false;
  bool shouldThrowOnUpdateCategory = false;
  bool shouldThrowOnDeleteCategory = false;

  String errorMessage = 'Mock error';
  int delayMs = 0;

  MockCategoryService() {
    reset();
  }

  void reset() {
    _categories.clear();
    _categoryOwners.clear();
    shouldThrowOnGetCategories = false;
    shouldThrowOnAddCategory = false;
    shouldThrowOnUpdateCategory = false;
    shouldThrowOnDeleteCategory = false;
    errorMessage = 'Mock error';
    delayMs = 0;
  }

  /// 테스트용 카테고리 추가 (사용자 지정)
  void seedCategories(List<Category> categories, {String? userId}) {
    final ownerId = userId ?? TestUsers.userId1;
    for (final cat in categories) {
      _categories.add(cat);
      _categoryOwners[cat.id] = ownerId;
    }
  }

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> _simulateDelay() async {
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  @override
  Future<List<Category>> getCategories(String userId) async {
    await _simulateDelay();
    if (shouldThrowOnGetCategories) throw Exception(errorMessage);
    return _categories
        .where((c) => _categoryOwners[c.id] == userId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Category> addCategory({
    required String userId,
    required String name,
    required String color,
  }) async {
    await _simulateDelay();
    if (shouldThrowOnAddCategory) throw Exception(errorMessage);

    // 중복 이름 체크 (같은 사용자 내에서)
    final userCats = _categories.where((c) => _categoryOwners[c.id] == userId);
    if (userCats.any((c) => c.name == name)) {
      throw Exception('Category already exists: $name');
    }

    final newCategory = Category(
      id: 'mock-cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );

    _categories.add(newCategory);
    _categoryOwners[newCategory.id] = userId;
    return newCategory;
  }

  @override
  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? color,
  }) async {
    await _simulateDelay();
    if (shouldThrowOnUpdateCategory) throw Exception(errorMessage);

    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) throw Exception('Category not found: $categoryId');

    final oldCat = _categories[index];
    _categories[index] = Category(
      id: oldCat.id,
      name: name ?? oldCat.name,
      color: color ?? oldCat.color,
      createdAt: oldCat.createdAt,
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _simulateDelay();
    if (shouldThrowOnDeleteCategory) throw Exception(errorMessage);

    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) throw Exception('Category not found: $categoryId');
    _categories.removeAt(index);
    _categoryOwners.remove(categoryId);
  }
}
