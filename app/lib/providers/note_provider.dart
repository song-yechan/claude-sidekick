/// 노트(수집한 문장) 상태 관리 Provider
///
/// 이 파일은 앱에서 노트 데이터를 관리하는 모든 Provider를 포함합니다.
/// 책에서 수집한 문장(노트)의 조회, 추가, 수정, 삭제 기능과
/// OCR 기능을 통한 이미지에서 텍스트 추출 기능을 제공합니다.
///
/// 주요 기능:
/// - 사용자별 노트 목록 관리 (notesProvider)
/// - 책별 노트 필터링 (notesByBookProvider)
/// - 날짜별 노트 수 집계 (noteCountsByDateProvider) - 활동 캘린더용
/// - OCR 이미지 처리 (ocrProvider)
library;

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/ocr_service.dart' show IOcrService, OcrService;
import 'auth_provider.dart';
import 'book_provider.dart' show reviewServiceProvider;

/// NoteService 인스턴스를 제공하는 Provider
final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

/// OcrService 인스턴스를 제공하는 Provider
/// Google Vision API를 사용한 OCR 기능을 담당합니다.
final ocrServiceProvider = Provider<IOcrService>((ref) => OcrService());

/// 현재 로그인한 사용자의 모든 노트 목록을 제공하는 Provider
///
/// authProvider를 구독하여 사용자 변경 시 자동으로 새로운 목록을 가져옵니다.
/// 최신 생성 순으로 정렬되어 반환됩니다.
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final authState = ref.watch(authProvider);
  final noteService = ref.watch(noteServiceProvider);

  print('📝 notesProvider - user: ${authState.user?.id}');

  // 로그인되지 않은 경우 빈 목록 반환
  if (authState.user == null) {
    print('📝 notesProvider - user is null, returning empty list');
    return [];
  }

  try {
    final notes = await noteService.getNotes(authState.user!.id);
    print('📝 notesProvider - fetched ${notes.length} notes');
    return notes;
  } catch (e) {
    print('📝 notesProvider - error: $e');
    rethrow;
  }
});

/// 특정 책에 속한 노트 목록을 제공하는 Family Provider
///
/// [bookId] 노트를 조회할 책의 고유 ID
/// 해당 책에 추가된 모든 노트를 반환합니다.
final notesByBookProvider =
    FutureProvider.family<List<Note>, String>((ref, bookId) async {
  final noteService = ref.watch(noteServiceProvider);
  return noteService.getNotesByBook(bookId);
});

/// 특정 ID의 노트를 조회하는 Family Provider
///
/// [noteId] 조회할 노트의 고유 ID
/// notesProvider에서 캐시된 목록을 사용합니다.
final noteProvider = Provider.family<Note?, String>((ref, noteId) {
  final notesAsync = ref.watch(notesProvider);
  return notesAsync.whenOrNull(
    data: (notes) => notes.where((n) => n.id == noteId).firstOrNull,
  );
});

/// 특정 연도의 날짜별 노트 수를 제공하는 Family Provider
///
/// [year] 집계할 연도
/// 홈 화면의 활동 캘린더(GitHub 스타일 잔디)에 사용됩니다.
/// 반환값은 {날짜: 해당 날짜의 노트 수} 형태의 Map입니다.
final noteCountsByDateProvider =
    FutureProvider.family<Map<DateTime, int>, int>((ref, year) async {
  final authState = ref.watch(authProvider);
  final noteService = ref.watch(noteServiceProvider);

  print('📅 noteCountsByDateProvider - user: ${authState.user?.id}, year: $year');

  if (authState.user == null) {
    print('📅 noteCountsByDateProvider - user is null');
    return {};
  }

  try {
    final counts = await noteService.getNoteCountsByDate(authState.user!.id, year);
    print('📅 noteCountsByDateProvider - fetched ${counts.length} entries');
    return counts;
  } catch (e) {
    print('📅 noteCountsByDateProvider - error: $e');
    rethrow;
  }
});

/// OCR 처리 상태를 나타내는 불변 클래스
///
/// 이미지에서 텍스트를 추출하는 OCR 프로세스의 현재 상태를 담습니다.
class OcrState {
  /// 처리 진행 중 여부
  final bool isProcessing;

  /// 추출된 원본 텍스트
  final String? extractedText;

  /// 에러 메시지 (처리 실패 시)
  final String? error;

  const OcrState({
    this.isProcessing = false,
    this.extractedText,
    this.error,
  });

  OcrState copyWith({
    bool? isProcessing,
    String? extractedText,
    String? error,
  }) {
    return OcrState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedText: extractedText ?? this.extractedText,
      error: error,
    );
  }
}

/// OCR 처리 기능을 관리하는 StateNotifier
///
/// 이미지를 받아 Google Vision API를 통해 텍스트를 추출합니다.
class OcrNotifier extends StateNotifier<OcrState> {
  final IOcrService _ocrService;

  OcrNotifier(this._ocrService) : super(const OcrState());

  /// 이미지에서 텍스트를 추출합니다.
  ///
  /// [imageBytes] 처리할 이미지의 바이트 데이터
  /// 성공 시 추출된 텍스트를 상태에 저장합니다.
  Future<void> processImage(Uint8List imageBytes) async {
    state = const OcrState(isProcessing: true);

    try {
      final result = await _ocrService.processImage(imageBytes);
      state = OcrState(
        extractedText: result.originalText,
      );
    } catch (e) {
      print('📷 OCR Error: $e');
      state = OcrState(error: e.toString());
    }
  }

  /// OCR 상태를 초기화합니다.
  void clear() {
    state = const OcrState();
  }
}

/// OCR 처리 상태를 관리하는 Provider
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return OcrNotifier(ocrService);
});

/// 새 노트를 추가합니다.
///
/// [ref] Riverpod WidgetRef
/// [bookId] 노트가 속할 책의 고유 ID (필수)
/// [content] 노트 본문 내용 (필수)
/// [summary] AI가 생성한 요약 (OCR 사용 시 자동 생성)
/// [pageNumber] 책의 페이지 번호
/// [tags] 노트에 추가할 태그 목록
/// [memo] 사용자 메모
///
/// 성공 시 생성된 Note 객체를 반환하고, 실패 시 null을 반환합니다.
/// 추가 후 관련 Provider들을 갱신합니다.
Future<Note?> addNote(
  WidgetRef ref, {
  required String bookId,
  required String content,
  String? summary,
  int? pageNumber,
  List<String> tags = const [],
  String? memo,
}) async {
  final authState = ref.read(authProvider);
  final noteService = ref.read(noteServiceProvider);

  if (authState.user == null) return null;

  try {
    final note = await noteService.addNote(
      userId: authState.user!.id,
      bookId: bookId,
      content: content,
      summary: summary,
      pageNumber: pageNumber,
      tags: tags,
      memo: memo,
    );

    // 전체 노트 목록과 해당 책의 노트 목록 모두 갱신
    ref.invalidate(notesProvider);
    ref.invalidate(notesByBookProvider(bookId));

    // 노트 3개 이상 작성 시 인앱 리뷰 요청
    final reviewService = ref.read(reviewServiceProvider);
    final notes = await noteService.getNotes(authState.user!.id);
    await reviewService.checkAndRequestReviewForNotes(notes.length);

    return note;
  } catch (e) {
    return null;
  }
}

/// 기존 노트를 수정합니다.
///
/// [ref] Riverpod WidgetRef
/// [noteId] 수정할 노트의 고유 ID
/// [content] 새 본문 내용
/// [summary] 새 요약
/// [pageNumber] 새 페이지 번호
/// [tags] 새 태그 목록
/// [memo] 새 메모
///
/// 성공 시 true, 실패 시 false를 반환합니다.
Future<bool> updateNote(
  WidgetRef ref,
  String noteId, {
  String? content,
  String? summary,
  int? pageNumber,
  List<String>? tags,
  String? memo,
}) async {
  final noteService = ref.read(noteServiceProvider);

  try {
    await noteService.updateNote(
      noteId: noteId,
      content: content,
      summary: summary,
      pageNumber: pageNumber,
      tags: tags,
      memo: memo,
    );
    ref.invalidate(notesProvider);
    return true;
  } catch (e) {
    return false;
  }
}

/// 노트를 삭제합니다.
///
/// [ref] Riverpod WidgetRef
/// [noteId] 삭제할 노트의 고유 ID
/// [bookId] 노트가 속한 책의 고유 ID (책 상세 페이지 갱신용)
///
/// 성공 시 true, 실패 시 false를 반환합니다.
Future<bool> deleteNote(WidgetRef ref, String noteId, {String? bookId}) async {
  final noteService = ref.read(noteServiceProvider);

  try {
    await noteService.deleteNote(noteId);
    ref.invalidate(notesProvider);
    // 책별 노트 목록도 갱신
    if (bookId != null) {
      ref.invalidate(notesByBookProvider(bookId));
    }
    return true;
  } catch (e) {
    return false;
  }
}
