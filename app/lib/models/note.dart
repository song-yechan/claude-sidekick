class Note {
  final String id;
  final String bookId;
  final String content;
  final String? summary;
  final int? pageNumber;
  final List<String> tags;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.bookId,
    required this.content,
    this.summary,
    this.pageNumber,
    this.tags = const [],
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String?,
      pageNumber: json['page_number'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'content': content,
      'summary': summary,
      'page_number': pageNumber,
      'tags': tags,
      'memo': memo,
    };
  }

  Note copyWith({
    String? id,
    String? bookId,
    String? content,
    String? summary,
    int? pageNumber,
    List<String>? tags,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      pageNumber: pageNumber ?? this.pageNumber,
      tags: tags ?? this.tags,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
