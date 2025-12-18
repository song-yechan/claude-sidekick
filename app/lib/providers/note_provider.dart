import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/ocr_service.dart';
import 'auth_provider.dart';

/// NoteService 프로바이더
final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

/// OcrService 프로바이더
final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());

/// 노트 목록 프로바이더
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final authState = ref.watch(authProvider);
  final noteService = ref.watch(noteServiceProvider);

  if (authState.user == null) return [];

  return noteService.getNotes(authState.user!.id);
});

/// 특정 책의 노트 목록 프로바이더
final notesByBookProvider =
    FutureProvider.family<List<Note>, String>((ref, bookId) async {
  final noteService = ref.watch(noteServiceProvider);
  return noteService.getNotesByBook(bookId);
});

/// 특정 노트 프로바이더
final noteProvider = Provider.family<Note?, String>((ref, noteId) {
  final notesAsync = ref.watch(notesProvider);
  return notesAsync.whenOrNull(
    data: (notes) => notes.where((n) => n.id == noteId).firstOrNull,
  );
});

/// 날짜별 노트 수 프로바이더 (활동 캘린더용)
final noteCountsByDateProvider =
    FutureProvider.family<Map<DateTime, int>, int>((ref, year) async {
  final authState = ref.watch(authProvider);
  final noteService = ref.watch(noteServiceProvider);

  if (authState.user == null) return {};

  return noteService.getNoteCountsByDate(authState.user!.id, year);
});

/// OCR 처리 상태
class OcrState {
  final bool isProcessing;
  final String? extractedText;
  final String? summary;
  final String? error;

  const OcrState({
    this.isProcessing = false,
    this.extractedText,
    this.summary,
    this.error,
  });

  OcrState copyWith({
    bool? isProcessing,
    String? extractedText,
    String? summary,
    String? error,
  }) {
    return OcrState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedText: extractedText ?? this.extractedText,
      summary: summary ?? this.summary,
      error: error,
    );
  }
}

/// OCR Notifier
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;

  OcrNotifier(this._ocrService) : super(const OcrState());

  Future<void> processImage(File imageFile) async {
    state = const OcrState(isProcessing: true);

    try {
      final result = await _ocrService.processImage(imageFile);
      state = OcrState(
        extractedText: result.originalText,
        summary: result.summary,
      );
    } catch (e) {
      state = OcrState(error: e.toString());
    }
  }

  void clear() {
    state = const OcrState();
  }
}

/// OCR 프로바이더
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return OcrNotifier(ocrService);
});

/// 노트 추가 함수
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

    ref.invalidate(notesProvider);
    ref.invalidate(notesByBookProvider(bookId));

    return note;
  } catch (e) {
    return null;
  }
}

/// 노트 수정 함수
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

/// 노트 삭제 함수
Future<bool> deleteNote(WidgetRef ref, String noteId) async {
  final noteService = ref.read(noteServiceProvider);

  try {
    await noteService.deleteNote(noteId);
    ref.invalidate(notesProvider);
    return true;
  } catch (e) {
    return false;
  }
}
