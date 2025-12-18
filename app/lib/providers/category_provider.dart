import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

/// CategoryService 프로바이더
final categoryServiceProvider =
    Provider<CategoryService>((ref) => CategoryService());

/// 카테고리 목록 프로바이더
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final authState = ref.watch(authProvider);
  final categoryService = ref.watch(categoryServiceProvider);

  if (authState.user == null) return [];

  return categoryService.getCategories(authState.user!.id);
});

/// 특정 카테고리 프로바이더
final categoryProvider = Provider.family<Category?, String>((ref, categoryId) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.whenOrNull(
    data: (categories) => categories.where((c) => c.id == categoryId).firstOrNull,
  );
});

/// 카테고리 추가 함수
Future<Category?> addCategory(WidgetRef ref, String name) async {
  final authState = ref.read(authProvider);
  final categoryService = ref.read(categoryServiceProvider);
  final categoriesAsync = ref.read(categoriesProvider);

  if (authState.user == null) return null;

  // 현재 카테고리 수로 색상 인덱스 결정
  final currentCount = categoriesAsync.whenOrNull(data: (c) => c.length) ?? 0;

  try {
    final category = await categoryService.addCategory(
      userId: authState.user!.id,
      name: name,
      colorIndex: currentCount,
    );

    ref.invalidate(categoriesProvider);
    return category;
  } catch (e) {
    return null;
  }
}

/// 카테고리 수정 함수
Future<bool> updateCategory(
  WidgetRef ref,
  String categoryId, {
  String? name,
  String? color,
}) async {
  final categoryService = ref.read(categoryServiceProvider);

  try {
    await categoryService.updateCategory(
      categoryId: categoryId,
      name: name,
      color: color,
    );
    ref.invalidate(categoriesProvider);
    return true;
  } catch (e) {
    return false;
  }
}

/// 카테고리 삭제 함수
Future<bool> deleteCategory(WidgetRef ref, String categoryId) async {
  final categoryService = ref.read(categoryServiceProvider);

  try {
    await categoryService.deleteCategory(categoryId);
    ref.invalidate(categoriesProvider);
    return true;
  } catch (e) {
    return false;
  }
}
