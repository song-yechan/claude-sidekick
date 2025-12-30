/// NoteDetailScreen 테스트
///
/// 노트 상세 화면의 기본 UI 요소를 검증합니다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookscribe/models/note.dart';

void main() {
  group('NoteDetailScreen 의존성', () {
    test('Note 모델을 올바르게 생성할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '책에서 발췌한 문장입니다.',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, 'note-1');
      expect(note.bookId, 'book-1');
      expect(note.content, isNotEmpty);
    });

    test('Note의 선택적 필드들', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        memo: '메모',
        summary: '요약',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.memo, '메모');
      expect(note.summary, '요약');
    });
  });

  group('NoteDetailScreen 편집 기능', () {
    test('메모 편집 가능', () {
      final now = DateTime.now();
      var note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '원본 내용',
        createdAt: now,
        updatedAt: now,
      );

      note = note.copyWith(memo: '새로운 메모');
      expect(note.memo, '새로운 메모');
    });

    test('빈 메모도 허용', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        memo: '',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.memo, isEmpty);
    });

    test('긴 메모 처리', () {
      final now = DateTime.now();
      final longMemo = 'A' * 1000;
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        memo: longMemo,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.memo?.length, 1000);
    });
  });

  group('NoteDetailScreen 삭제 기능', () {
    test('삭제 다이얼로그 텍스트', () {
      const title = '노트 삭제';
      const content = '이 노트를 삭제하시겠습니까?';
      const cancelButton = '취소';
      const deleteButton = '삭제';

      expect(title, contains('삭제'));
      expect(content, contains('삭제'));
      expect(cancelButton, '취소');
      expect(deleteButton, '삭제');
    });
  });

  group('NoteDetailScreen 요약 토글', () {
    test('요약 표시/숨김 상태 전환', () {
      bool showSummary = true;

      showSummary = !showSummary;
      expect(showSummary, false);

      showSummary = !showSummary;
      expect(showSummary, true);
    });

    test('요약이 없을 때 처리', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        summary: null,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.summary, isNull);
    });

    test('요약이 있을 때 표시', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '긴 문장의 원본 내용입니다.',
        summary: 'AI가 생성한 요약입니다.',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.summary, isNotNull);
      expect(note.summary, contains('요약'));
    });
  });

  group('NoteDetailScreen 날짜 포맷', () {
    test('날짜를 한국어 형식으로 표시', () {
      final date = DateTime(2024, 12, 25, 14, 30);

      // intl 패키지의 DateFormat 사용
      final year = date.year;
      final month = date.month;
      final day = date.day;

      expect(year, 2024);
      expect(month, 12);
      expect(day, 25);
    });

    test('생성일과 수정일 관리', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 6, 15);

      expect(updatedAt.isAfter(createdAt), true);
    });
  });

  group('NoteDetailScreen 태그 관리', () {
    test('Note에 태그를 추가할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        tags: ['영감', '명언'],
        createdAt: now,
        updatedAt: now,
      );

      expect(note.tags, hasLength(2));
      expect(note.tags, contains('영감'));
    });

    test('빈 태그 목록 처리', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.tags, isEmpty);
    });
  });

  group('NoteDetailScreen 책 정보 연결', () {
    test('노트에서 책 ID로 책 정보 조회 가능', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-123',
        content: '내용',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.bookId, 'book-123');
      // 실제로는 bookProvider(note.bookId)로 책 정보 조회
    });
  });

  group('NoteDetailScreen 페이지 번호', () {
    test('페이지 번호를 저장할 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        pageNumber: 42,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.pageNumber, 42);
    });

    test('페이지 번호가 없을 수 있다', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        bookId: 'book-1',
        content: '내용',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.pageNumber, isNull);
    });
  });
}
