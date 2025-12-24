/// 카테고리 상태 관리 Provider
///
/// 이 파일은 앱에서 카테고리 데이터를 관리하는 모든 Provider를 포함합니다.
/// 책을 분류하기 위한 카테고리의 조회, 추가, 수정, 삭제 기능을 제공합니다.
///
/// 주요 기능:
/// - 사용자별 카테고리 목록 관리 (categoriesProvider)
/// - 카테고리 CRUD 함수들
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

/// CategoryService 인스턴스를 제공하는 Provider
final categoryServiceProvider =
    Provider<CategoryService>((ref) => CategoryService());

/// 현재 로그인한 사용자의 카테고리 목록을 제공하는 Provider
///
/// authProvider를 구독하여 사용자 변경 시 자동으로 새로운 목록을 가져옵니다.
/// 로그인되지 않은 경우 빈 목록을 반환합니다.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final authState = ref.watch(authProvider);
  final categoryService = ref.watch(categoryServiceProvider);

  if (authState.user == null) return [];

  return categoryService.getCategories(authState.user!.id);
});

/// 특정 ID의 카테고리를 조회하는 Family Provider
///
/// [categoryId] 조회할 카테고리의 고유 ID
/// categoriesProvider에서 캐시된 목록을 사용합니다.
final categoryProvider = Provider.family<Category?, String>((ref, categoryId) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.whenOrNull(
    data: (categories) => categories.where((c) => c.id == categoryId).firstOrNull,
  );
});

/// 새 카테고리를 추가합니다.
///
/// [ref] Riverpod WidgetRef
/// [name] 카테고리 이름
///
/// 색상은 현재 카테고리 수를 기반으로 자동 할당됩니다.
/// 성공 시 생성된 Category 객체를 반환하고, 실패 시 null을 반환합니다.
Future<Category?> addCategory(WidgetRef ref, String name) async {
  final authState = ref.read(authProvider);
  final categoryService = ref.read(categoryServiceProvider);
  final categoriesAsync = ref.read(categoriesProvider);

  if (authState.user == null) return null;

  // 현재 카테고리 수로 색상 인덱스 결정 (순환 색상 팔레트 사용)
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

/// 기존 카테고리를 수정합니다.
///
/// [ref] Riverpod WidgetRef
/// [categoryId] 수정할 카테고리의 고유 ID
/// [name] 새 카테고리 이름
/// [color] 새 색상
///
/// 성공 시 true, 실패 시 false를 반환합니다.
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

/// 카테고리를 삭제합니다.
///
/// [ref] Riverpod WidgetRef
/// [categoryId] 삭제할 카테고리의 고유 ID
///
/// 성공 시 true, 실패 시 false를 반환합니다.
/// 주의: 해당 카테고리에 속한 책들의 categoryIds에서 이 ID가 제거됩니다.
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
