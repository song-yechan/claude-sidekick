import '../core/supabase.dart';
import '../models/book.dart';

class BookService {
  /// 사용자의 모든 책 조회
  Future<List<Book>> getBooks(String userId) async {
    final response = await supabase
        .from('books')
        .select('''
          *,
          book_categories(category_id)
        ''')
        .eq('user_id', userId)
        .order('added_at', ascending: false);

    return (response as List).map((json) {
      final categoryIds = (json['book_categories'] as List?)
              ?.map((bc) => bc['category_id'] as String)
              .toList() ??
          [];
      return Book.fromJson(json, categoryIds: categoryIds);
    }).toList();
  }

  /// 책 추가
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
    // 책 추가
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

    // 카테고리 연결
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

  /// 책 수정
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
    // 책 정보 업데이트
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

    // 카테고리 업데이트
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

  /// 책 삭제
  Future<void> deleteBook(String bookId) async {
    await supabase.from('books').delete().eq('id', bookId);
  }

  /// 도서 검색 (Edge Function)
  Future<List<BookSearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await supabase.functions.invoke(
      'book-search',
      body: {'query': query},
    );

    if (response.data == null) return [];

    final items = response.data['items'] as List? ?? [];
    return items.map((json) => BookSearchResult.fromJson(json)).toList();
  }
}
