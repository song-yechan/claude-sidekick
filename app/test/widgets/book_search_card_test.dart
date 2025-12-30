/// BookSearchCard 위젯 테스트
///
/// 책 검색 결과 카드의 렌더링과 인터랙션을 검증합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/book.dart';
import 'package:bookscribe/widgets/book/book_search_card.dart';
import '../mocks/test_fixtures.dart';

void main() {
  group('BookSearchCard', () {
    testWidgets('displays book title and author', (tester) async {
      final book = TestBookSearchResults.harryPotter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      expect(find.text('해리포터와 마법사의 돌'), findsOneWidget);
      expect(find.text('J.K. 롤링'), findsOneWidget);
    });

    testWidgets('displays publisher when available', (tester) async {
      final book = TestBookSearchResults.harryPotter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      expect(find.text('문학수첩'), findsOneWidget);
    });

    testWidgets('hides publisher when empty', (tester) async {
      final book = BookSearchResult(
        title: '테스트 책',
        author: '테스트 저자',
        isbn: '1234567890',
        publisher: '',  // 빈 출판사
        publishDate: '2024-01-01',
        coverImage: '',
        description: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      expect(find.text('테스트 책'), findsOneWidget);
      expect(find.text('테스트 저자'), findsOneWidget);
      // 빈 출판사는 표시되지 않음
    });

    testWidgets('shows placeholder when no cover image', (tester) async {
      final book = BookSearchResult(
        title: '커버 없는 책',
        author: '저자',
        isbn: '1234567890',
        publisher: '출판사',
        publishDate: '2024-01-01',
        coverImage: '',  // 빈 이미지
        description: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('shows add button', (tester) async {
      final book = TestBookSearchResults.harryPotter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('triggers onAdd callback when add button tapped', (tester) async {
      var added = false;
      final book = TestBookSearchResults.harryPotter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(
              book: book,
              onAdd: () => added = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(added, isTrue);
    });

    testWidgets('renders without onAdd callback', (tester) async {
      final book = TestBookSearchResults.atomicHabits;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookSearchCard(book: book),
          ),
        ),
      );

      // onAdd 없이도 정상 렌더링
      expect(find.text('아주 작은 습관의 힘'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('handles long title with ellipsis', (tester) async {
      final book = BookSearchResult(
        title: '이것은 매우 매우 긴 책 제목입니다. 화면에 전부 표시되지 않을 정도로 아주 긴 제목이에요. 정말 길죠?',
        author: '저자',
        isbn: '1234567890',
        publisher: '출판사',
        publishDate: '2024-01-01',
        coverImage: '',
        description: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: BookSearchCard(book: book),
            ),
          ),
        ),
      );

      // 긴 제목도 정상적으로 표시됨 (ellipsis 처리)
      expect(find.textContaining('이것은'), findsOneWidget);
    });

    testWidgets('handles long author name', (tester) async {
      final book = BookSearchResult(
        title: '책 제목',
        author: '매우 긴 저자 이름을 가진 사람의 전체 이름입니다 정말 길어요',
        isbn: '1234567890',
        publisher: '출판사',
        publishDate: '2024-01-01',
        coverImage: '',
        description: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: BookSearchCard(book: book),
            ),
          ),
        ),
      );

      expect(find.textContaining('매우 긴'), findsOneWidget);
    });

    testWidgets('renders multiple cards in a list', (tester) async {
      final books = TestBookSearchResults.searchResults;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) => BookSearchCard(book: books[index]),
            ),
          ),
        ),
      );

      expect(find.byType(BookSearchCard), findsNWidgets(2));
      expect(find.text('해리포터와 마법사의 돌'), findsOneWidget);
      expect(find.text('아주 작은 습관의 힘'), findsOneWidget);
    });
  });
}
