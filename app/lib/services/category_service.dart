import '../core/supabase.dart';
import '../core/constants.dart';
import '../models/category.dart';

class CategoryService {
  /// 사용자의 모든 카테고리 조회
  Future<List<Category>> getCategories(String userId) async {
    final response = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  /// 카테고리 추가
  Future<Category> addCategory({
    required String userId,
    required String name,
    int colorIndex = 0,
  }) async {
    final color = categoryColors[colorIndex % categoryColors.length];

    final response = await supabase
        .from('categories')
        .insert({
          'user_id': userId,
          'name': name,
          'color': color,
        })
        .select()
        .single();

    return Category.fromJson(response);
  }

  /// 카테고리 수정
  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? color,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (color != null) updates['color'] = color;

    if (updates.isNotEmpty) {
      await supabase.from('categories').update(updates).eq('id', categoryId);
    }
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String categoryId) async {
    await supabase.from('categories').delete().eq('id', categoryId);
  }
}
