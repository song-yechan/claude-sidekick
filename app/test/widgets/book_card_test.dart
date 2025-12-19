import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/book.dart';
import 'package:bookscribe/widgets/book/book_card.dart';

void main() {
  group('BookCard', () {
    late Book testBook;

    setUp(() {
      testBook = Book(
        id: 'book-123',
        title: '테스트 책 제목',
        author: '테스트 저자',
        addedAt: DateTime.now(),
      );
    });

    testWidgets('displays book title and author', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: BookCard(book: testBook),
            ),
          ),
        ),
      );

      expect(find.text('테스트 책 제목'), findsOneWidget);
      expect(find.text('테스트 저자'), findsOneWidget);
    });

    testWidgets('shows placeholder when no cover image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: BookCard(book: testBook),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: BookCard(
                book: testBook,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BookCard));
      expect(tapped, isTrue);
    });

    testWidgets('handles long title with ellipsis', (tester) async {
      final longTitleBook = Book(
        id: 'book-123',
        title: '이것은 매우 긴 책 제목입니다. 화면에 다 표시되지 않을 정도로 아주 긴 제목이에요.',
        author: '저자',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 150,
              child: BookCard(book: longTitleBook),
            ),
          ),
        ),
      );

      // Text widget should exist even with long title
      expect(find.textContaining('이것은'), findsOneWidget);
    });

    testWidgets('handles long author name', (tester) async {
      final longAuthorBook = Book(
        id: 'book-123',
        title: '책 제목',
        author: '매우 긴 저자 이름을 가진 사람의 이름입니다',
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 150,
              child: BookCard(book: longAuthorBook),
            ),
          ),
        ),
      );

      expect(find.textContaining('매우 긴'), findsOneWidget);
    });

    testWidgets('renders correctly with all optional fields', (tester) async {
      final fullBook = Book(
        id: 'book-123',
        isbn: '978-1234567890',
        title: '완전한 책',
        author: '완전한 저자',
        publisher: '출판사',
        publishDate: '2024-01-01',
        coverImage: '', // Empty string should show placeholder
        description: '설명',
        categoryIds: ['cat-1', 'cat-2'],
        addedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: BookCard(book: fullBook),
            ),
          ),
        ),
      );

      expect(find.text('완전한 책'), findsOneWidget);
      expect(find.text('완전한 저자'), findsOneWidget);
    });
  });
}
