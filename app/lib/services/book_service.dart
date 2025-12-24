/// 책 서비스
///
/// Supabase Database를 사용하여 책 데이터의 CRUD 작업을 처리합니다.
/// 책-카테고리 다대다 관계도 함께 관리합니다.
///
/// 주요 테이블:
/// - books: 책 정보 저장
/// - book_categories: 책-카테고리 연결 (다대다 관계)
library;

import '../core/supabase.dart';
import '../models/book.dart';

/// 책 데이터 CRUD 및 검색 기능을 제공하는 서비스 클래스
class BookService {
  /// 특정 사용자의 모든 책을 조회합니다.
  ///
  /// [userId] 조회할 사용자의 ID
  ///
  /// 책 정보와 함께 연결된 카테고리 ID 목록도 함께 가져옵니다.
  /// 최신 등록순으로 정렬됩니다.
  Future<List<Book>> getBooks(String userId) async {
    // books 테이블과 book_categories 테이블을 조인하여 조회
    final response = await supabase
        .from('books')
        .select('''
          *,
          book_categories(category_id)
        ''')
        .eq('user_id', userId)
        .order('added_at', ascending: false);

    return (response as List).map((json) {
      // 조인된 카테고리 ID들을 추출
      final categoryIds = (json['book_categories'] as List?)
              ?.map((bc) => bc['category_id'] as String)
              .toList() ??
          [];
      return Book.fromJson(json, categoryIds: categoryIds);
    }).toList();
  }

  /// 새 책을 추가합니다.
  ///
  /// 책 정보를 저장한 후, 카테고리 연결도 함께 처리합니다.
  /// 반환값: 생성된 Book 객체
  Future<Book> addBook({
    required String userId,
    required String title,
    required String author,
    String? isbn,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    List<String> categoryIds = const [],
  }) async {
    // 1단계: books 테이블에 책 정보 추가
    final bookResponse = await supabase
        .from('books')
        .insert({
          'user_id': userId,
          'isbn': isbn,
          'title': title,
          'author': author,
          'publisher': publisher,
          'publish_date': publishDate,
          'cover_image': coverImage,
          'description': description,
        })
        .select()
        .single();

    final bookId = bookResponse['id'] as String;

    // 2단계: book_categories 테이블에 카테고리 연결
    if (categoryIds.isNotEmpty) {
      await supabase.from('book_categories').insert(
            categoryIds
                .map((catId) => {
                      'book_id': bookId,
                      'category_id': catId,
                    })
                .toList(),
          );
    }

    return Book.fromJson(bookResponse, categoryIds: categoryIds);
  }

  /// 기존 책 정보를 수정합니다.
  ///
  /// null이 아닌 필드만 업데이트됩니다.
  /// categoryIds가 제공되면 기존 카테고리 연결을 모두 삭제하고 새로 설정합니다.
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    List<String>? categoryIds,
  }) async {
    // 책 정보 업데이트 (변경된 필드만)
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (author != null) updates['author'] = author;
    if (isbn != null) updates['isbn'] = isbn;
    if (publisher != null) updates['publisher'] = publisher;
    if (publishDate != null) updates['publish_date'] = publishDate;
    if (coverImage != null) updates['cover_image'] = coverImage;
    if (description != null) updates['description'] = description;

    if (updates.isNotEmpty) {
      await supabase.from('books').update(updates).eq('id', bookId);
    }

    // 카테고리 업데이트: 기존 연결 삭제 후 새로 추가
    if (categoryIds != null) {
      await supabase.from('book_categories').delete().eq('book_id', bookId);

      if (categoryIds.isNotEmpty) {
        await supabase.from('book_categories').insert(
              categoryIds
                  .map((catId) => {
                        'book_id': bookId,
                        'category_id': catId,
                      })
                  .toList(),
            );
      }
    }
  }

  /// 책을 삭제합니다.
  ///
  /// [bookId] 삭제할 책의 ID
  /// 연결된 book_categories 레코드는 CASCADE로 자동 삭제됩니다.
  Future<void> deleteBook(String bookId) async {
    await supabase.from('books').delete().eq('id', bookId);
  }

  /// 알라딘 API를 통해 도서를 검색합니다.
  ///
  /// [query] 검색어 (제목, 저자 등)
  ///
  /// Supabase Edge Function(book-search)을 호출하여 검색을 수행합니다.
  /// 반환값: 검색 결과 목록
  Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await supabase.functions.invoke(
      'book-search',
      body: {'query': query},
    );

    if (response.data == null) {
      return [];
    }

    final items = response.data['items'] as List? ?? [];
    return items.map((json) => BookSearchResult.fromJson(json as Map<String, dynamic>)).toList();
  }
}
