class Book {
  final String id;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final String? publishDate;
  final String? coverImage;
  final String? description;
  final int? pageCount;
  final List<String> categoryIds;
  final DateTime addedAt;

  Book({
    required this.id,
    this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    this.publishDate,
    this.coverImage,
    this.description,
    this.pageCount,
    this.categoryIds = const [],
    required this.addedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json, {List<String>? categoryIds}) {
    return Book(
      id: json['id'] as String,
      isbn: json['isbn'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String?,
      publishDate: json['publish_date'] as String?,
      coverImage: json['cover_image'] as String?,
      description: json['description'] as String?,
      pageCount: json['page_count'] as int?,
      categoryIds: categoryIds ?? [],
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publish_date': publishDate,
      'cover_image': coverImage,
      'description': description,
      'page_count': pageCount,
    };
  }

  Book copyWith({
    String? id,
    String? isbn,
    String? title,
    String? author,
    String? publisher,
    String? publishDate,
    String? coverImage,
    String? description,
    int? pageCount,
    List<String>? categoryIds,
    DateTime? addedAt,
  }) {
    return Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      publishDate: publishDate ?? this.publishDate,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      categoryIds: categoryIds ?? this.categoryIds,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class BookSearchResult {
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String publishDate;
  final String coverImage;
  final String description;
  final int? pageCount;

  BookSearchResult({
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publishDate,
    required this.coverImage,
    required this.description,
    this.pageCount,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      isbn: json['isbn'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      publishDate: json['publishDate'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pageCount: json['pageCount'] as int?,
    );
  }
}
