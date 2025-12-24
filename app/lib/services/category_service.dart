/// 카테고리 서비스
///
/// Supabase Database를 사용하여 카테고리 데이터의 CRUD 작업을 처리합니다.
/// 카테고리는 책을 분류하기 위한 태그 역할을 합니다.
///
/// 주요 테이블:
/// - categories: 카테고리 정보 저장
library;

import '../core/supabase.dart';
import '../core/constants.dart';
import '../models/category.dart';

/// 카테고리 데이터 CRUD 기능을 제공하는 서비스 클래스
class CategoryService {
  /// 특정 사용자의 모든 카테고리를 조회합니다.
  ///
  /// [userId] 조회할 사용자의 ID
  /// 최신 생성순으로 정렬됩니다.
  Future<List<Category>> getCategories(String userId) async {
    final response = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  /// 새 카테고리를 추가합니다.
  ///
  /// [userId] 사용자 ID
  /// [name] 카테고리 이름
  /// [colorIndex] 색상 인덱스 (순환 팔레트에서 선택)
  ///
  /// 색상은 constants.dart에 정의된 categoryColors 배열에서 선택됩니다.
  /// 반환값: 생성된 Category 객체
  Future<Category> addCategory({
    required String userId,
    required String name,
    int colorIndex = 0,
  }) async {
    // 인덱스가 색상 배열 범위를 넘어가면 처음부터 순환
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

  /// 기존 카테고리를 수정합니다.
  ///
  /// [categoryId] 수정할 카테고리의 ID
  /// [name] 새 카테고리 이름 (선택)
  /// [color] 새 색상 값 (선택)
  ///
  /// null이 아닌 필드만 업데이트됩니다.
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

  /// 카테고리를 삭제합니다.
  ///
  /// [categoryId] 삭제할 카테고리의 ID
  /// 연결된 book_categories 레코드는 CASCADE로 자동 삭제됩니다.
  Future<void> deleteCategory(String categoryId) async {
    await supabase.from('categories').delete().eq('id', categoryId);
  }
}
