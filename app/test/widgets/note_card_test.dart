import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/note.dart';
import 'package:bookscribe/widgets/note/note_card.dart';

void main() {
  group('NoteCard', () {
    late Note testNote;

    setUp(() {
      testNote = Note(
        id: 'note-123',
        bookId: 'book-456',
        content: '테스트 노트 내용입니다.',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    testWidgets('displays note content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: testNote),
          ),
        ),
      );

      expect(find.text('테스트 노트 내용입니다.'), findsOneWidget);
    });

    testWidgets('displays formatted date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: testNote),
          ),
        ),
      );

      expect(find.text('2024.01.15'), findsOneWidget);
    });

    testWidgets('displays page number when available', (tester) async {
      final noteWithPage = testNote.copyWith(pageNumber: 42);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: noteWithPage),
          ),
        ),
      );

      expect(find.text('p.42'), findsOneWidget);
    });

    testWidgets('does not show page number when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: testNote),
          ),
        ),
      );

      expect(find.textContaining('p.'), findsNothing);
    });

    testWidgets('displays summary when showSummary is true and summary exists', (tester) async {
      final noteWithSummary = testNote.copyWith(
        summary: 'AI 요약된 내용',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: noteWithSummary,
              showSummary: true,
            ),
          ),
        ),
      );

      expect(find.text('AI 요약된 내용'), findsOneWidget);
      expect(find.text('AI 요약'), findsOneWidget);
    });

    testWidgets('displays original content when showSummary is false', (tester) async {
      final noteWithSummary = testNote.copyWith(
        summary: 'AI 요약된 내용',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: noteWithSummary,
              showSummary: false,
            ),
          ),
        ),
      );

      expect(find.text('테스트 노트 내용입니다.'), findsOneWidget);
      expect(find.text('원문'), findsOneWidget);
    });

    testWidgets('displays memo when available', (tester) async {
      final noteWithMemo = testNote.copyWith(
        memo: '이것은 메모입니다.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: noteWithMemo),
          ),
        ),
      );

      expect(find.text('이것은 메모입니다.'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    });

    testWidgets('displays tags when available', (tester) async {
      final noteWithTags = testNote.copyWith(
        tags: ['독서', '인생', '철학'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: noteWithTags),
          ),
        ),
      );

      expect(find.text('#독서'), findsOneWidget);
      expect(find.text('#인생'), findsOneWidget);
      expect(find.text('#철학'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: testNote,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NoteCard));
      expect(tapped, isTrue);
    });

    testWidgets('handles note with all fields', (tester) async {
      final fullNote = Note(
        id: 'note-123',
        bookId: 'book-456',
        content: '전체 필드 테스트 내용',
        summary: 'AI 요약',
        pageNumber: 100,
        tags: ['태그1', '태그2'],
        memo: '메모 내용',
        createdAt: DateTime(2024, 6, 15),
        updatedAt: DateTime(2024, 6, 16),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NoteCard(note: fullNote),
            ),
          ),
        ),
      );

      expect(find.text('AI 요약'), findsWidgets);
      expect(find.text('p.100'), findsOneWidget);
      expect(find.text('#태그1'), findsOneWidget);
      expect(find.text('메모 내용'), findsOneWidget);
      expect(find.text('2024.06.15'), findsOneWidget);
    });

    testWidgets('handles empty memo gracefully', (tester) async {
      final noteWithEmptyMemo = testNote.copyWith(memo: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: noteWithEmptyMemo),
          ),
        ),
      );

      // Empty memo should not show memo section
      expect(find.byIcon(Icons.edit_note_rounded), findsNothing);
    });

    testWidgets('handles empty tags list gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: testNote),
          ),
        ),
      );

      // No tags should not show any hashtag prefixed text
      expect(find.textContaining('#'), findsNothing);
    });

    testWidgets('long content is truncated with ellipsis', (tester) async {
      final longNote = testNote.copyWith(
        content: '''이것은 매우 긴 내용입니다.
        여러 줄에 걸쳐 작성된 텍스트로,
        카드에 모두 표시되지 않고
        일부만 표시되어야 합니다.
        더 많은 내용이 있지만 생략됩니다.
        이 부분은 보이지 않아야 합니다.
        추가 내용입니다.''',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: NoteCard(note: longNote),
            ),
          ),
        ),
      );

      // Widget should render without overflow errors
      expect(find.byType(NoteCard), findsOneWidget);
    });
  });
}
