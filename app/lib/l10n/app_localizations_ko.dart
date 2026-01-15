// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '북스크라이브';

  @override
  String get common_confirm => '확인';

  @override
  String get common_cancel => '취소';

  @override
  String get common_delete => '삭제';

  @override
  String get common_save => '저장';

  @override
  String get common_saving => '저장하기';

  @override
  String get common_edit => '수정';

  @override
  String get common_next => '다음';

  @override
  String get common_skip => '건너뛰기';

  @override
  String get common_done => '완료';

  @override
  String get common_retry => '다시 시도';

  @override
  String get common_add => '추가하기';

  @override
  String get common_preview => '미리보기';

  @override
  String get common_start => '시작하기';

  @override
  String get common_startNow => '바로 시작하기';

  @override
  String get common_preparing => '준비 중...';

  @override
  String get common_version => '버전';

  @override
  String get auth_login => '로그인';

  @override
  String get auth_logout => '로그아웃';

  @override
  String get auth_signUp => '회원가입';

  @override
  String get auth_signUpButton => '가입하기';

  @override
  String get auth_email => '이메일';

  @override
  String get auth_password => '비밀번호';

  @override
  String get auth_passwordConfirm => '비밀번호 확인';

  @override
  String get auth_emailPlaceholder => '이메일을 입력해주세요';

  @override
  String get auth_passwordPlaceholder => '비밀번호를 입력해주세요';

  @override
  String get auth_passwordConfirmPlaceholder => '비밀번호를 다시 입력해주세요';

  @override
  String get auth_noAccount => '계정이 없으신가요? 회원가입';

  @override
  String get auth_hasAccount => '이미 계정이 있으신가요? 로그인';

  @override
  String get auth_loginRequired => '로그인 필요';

  @override
  String get auth_loginRequiredMessage => '로그인이 필요합니다';

  @override
  String get auth_logoutConfirm => '정말 로그아웃 하시겠습니까?';

  @override
  String get auth_welcomeBack => '다시 만나서 반가워요';

  @override
  String get auth_welcome => '환영합니다!';

  @override
  String get auth_welcomeWithEmoji => '환영합니다! 👋';

  @override
  String get auth_simpleSignUp => '간단한 가입으로 시작하세요';

  @override
  String get auth_quickStart => '30초면 시작할 수 있어요';

  @override
  String get auth_error_invalidEmail => '올바른 이메일 형식이 아닙니다';

  @override
  String get auth_error_invalidEmailWithPeriod => '올바른 이메일 형식이 아닙니다.';

  @override
  String get auth_error_passwordTooShort => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get auth_error_passwordTooShortWithPeriod => '비밀번호는 6자 이상이어야 합니다.';

  @override
  String get auth_error_passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get auth_error_minLength => '6자 이상 입력해주세요';

  @override
  String get auth_error_loginFailed => '로그인에 실패했습니다.';

  @override
  String get auth_error_signUpFailed => '회원가입에 실패했습니다.';

  @override
  String get auth_error_wrongCredentials => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get auth_error_emailExists => '이미 가입된 이메일입니다.';

  @override
  String get auth_error_emailVerification => '이메일 인증이 필요합니다.';

  @override
  String get account_title => '계정';

  @override
  String get account_info => '계정 정보';

  @override
  String get account_loggedIn => '로그인된 계정';

  @override
  String get account_delete => '계정 삭제';

  @override
  String get account_deleteConfirm => '계정을 삭제하면 다음 데이터가 영구적으로 삭제됩니다:';

  @override
  String get account_deleteWarning => '모든 데이터가 영구적으로 삭제됩니다';

  @override
  String get account_deleteIrreversible => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get account_deleting => '계정을 삭제하는 중...';

  @override
  String get account_deleteFailed => '계정 삭제에 실패했습니다. 다시 시도해주세요.';

  @override
  String get onboarding_selectStyle => '온보딩 스타일을 선택하세요';

  @override
  String get onboarding_styleSelection => '온보딩 시안 선택';

  @override
  String get onboarding_previewSelected => '선택한 시안 미리보기';

  @override
  String get onboarding_selectFromThree => '3가지 시안 중 하나를 선택하여 미리볼 수 있습니다';

  @override
  String get onboarding_style1Title => '시안 1: 혜택 중심형';

  @override
  String get onboarding_style1Desc => 'Calm, Blinkist 스타일\n슬라이드로 주요 기능과 혜택 소개';

  @override
  String get onboarding_style2Title => '시안 2: 인터랙티브형';

  @override
  String get onboarding_style2Desc =>
      'Spotify, Duolingo 스타일\n사용자 목표를 묻고 개인화된 경험 제공';

  @override
  String get onboarding_style3Title => '시안 3: 미니멀 빠른시작';

  @override
  String get onboarding_style3Desc => 'Loom 스타일\n단일 페이지로 핵심만 빠르게 전달';

  @override
  String get onboarding_hello => '안녕하세요';

  @override
  String get onboarding_customExperience => '맞춤 경험을 제공해드릴게요';

  @override
  String get onboarding_whatDoYouWant => '북스크라이브를 통해\n무엇을 하고 싶으세요?';

  @override
  String get onboarding_multiSelect => '여러 개를 선택할 수 있어요';

  @override
  String get onboarding_collectSentences => '좋은 문장 수집하기';

  @override
  String get onboarding_keepRecord => '독서 기록 남기기';

  @override
  String get onboarding_rememberContent => '읽은 내용 기억하기';

  @override
  String get onboarding_buildHabit => '독서 습관 만들기';

  @override
  String get onboarding_howOften => '얼마나 자주\n책을 읽으시나요?';

  @override
  String get onboarding_freqHigh => '많음';

  @override
  String get onboarding_freqMedium => '주 2-3회';

  @override
  String get onboarding_freqLow => '적음';

  @override
  String get onboarding_freqOccasional => '여유 있을 때';

  @override
  String get onboarding_benefit_title1 => '책 속 문장을 수집하세요';

  @override
  String get onboarding_benefit_desc1 => '책 속 마음에 드는 문장을\n카메라로 간편하게 촬영하세요';

  @override
  String get onboarding_benefit_title2 => '문장을 찍으면 텍스트로 변환';

  @override
  String get onboarding_benefit_desc2 => '촬영한 문장을 자동으로 인식하고\nAI가 핵심만 요약해드립니다';

  @override
  String get onboarding_benefit_title3 => '독서 습관을 만드세요';

  @override
  String get onboarding_benefit_desc3 => '매일의 독서 기록이 쌓여\n나만의 독서 캘린더가 완성됩니다';

  @override
  String get onboarding_benefit_title4 => '나만의 독서 기록';

  @override
  String get onboarding_benefit_desc4 => '이제 BookScribe와 함께\n책 속 문장을 수집해보세요';

  @override
  String get onboarding_minimal_headline => '책 속 문장을 나만의 기록으로';

  @override
  String get onboarding_minimal_subhead => '책 속 문장을 기록하는 가장 스마트한 방법';

  @override
  String get onboarding_minimal_cta => '북스크라이브와 함께\n더 풍요로운 독서 생활을 시작해보세요';

  @override
  String get onboarding_habit_title => '꾸준함이 중요해요';

  @override
  String get onboarding_habit_daily => '매일 조금씩';

  @override
  String get onboarding_habit_10min => '하루 10분이면 충분해요';

  @override
  String get onboarding_habit_noStress => '부담 없이 즐기세요';

  @override
  String get nav_home => '홈';

  @override
  String get nav_search => '검색';

  @override
  String get nav_library => '서재';

  @override
  String get nav_categories => '카테고리';

  @override
  String get home_recentNotes => '최근 수집한 문장';

  @override
  String get home_noNotes => '아직 수집한 문장이 없어요';

  @override
  String get home_addBook => '책을 등록하고 마음에 드는 문장을 저장해보세요';

  @override
  String get search_title => '책 검색';

  @override
  String get search_searchBooks => '책 검색하기';

  @override
  String get search_placeholder => '책 제목, 저자, ISBN으로 검색';

  @override
  String get search_hint => '제목, 저자, ISBN으로 검색할 수 있어요';

  @override
  String get search_try => '책을 검색해보세요';

  @override
  String get search_failed => '검색에 실패했어요';

  @override
  String get search_addToLibrary => '서재에 추가';

  @override
  String get library_title => '내 서재';

  @override
  String get library_noBooks => '아직 등록된 책이 없어요';

  @override
  String get library_addFromSearch => '검색 탭에서 책을 추가해보세요';

  @override
  String get library_allBooks => '등록한 모든 책';

  @override
  String get library_registeredBooks => '등록한 책';

  @override
  String get library_allNotes => '수집한 모든 문장';

  @override
  String get library_collectedNotes => '수집한 문장';

  @override
  String library_bookCount(int count) {
    return '$count권';
  }

  @override
  String get book_delete => '책 삭제';

  @override
  String book_deleteConfirm(String title) {
    return '$title을(를) 삭제하시겠습니까?\n모든 노트도 함께 삭제됩니다.';
  }

  @override
  String book_added(String title) {
    return '$title이(가) 추가되었습니다';
  }

  @override
  String get book_deleted => '책이 삭제되었습니다';

  @override
  String get book_addFailed => '책 추가에 실패했습니다';

  @override
  String get book_notFound => '책을 찾을 수 없습니다';

  @override
  String get book_alreadyExists => '이미 등록된 책';

  @override
  String get book_alreadyInLibrary => '서재에 같은 책이 이미 있어요.';

  @override
  String get book_addAnyway => '그래도 추가';

  @override
  String get book_addAnywayConfirm => '그래도 추가하시겠어요?';

  @override
  String get category_title => '카테고리';

  @override
  String get category_new => '새 카테고리';

  @override
  String get category_add => '카테고리 추가';

  @override
  String get category_edit => '카테고리 수정';

  @override
  String get category_delete => '카테고리 삭제';

  @override
  String get category_name => '카테고리 이름';

  @override
  String get category_namePlaceholder => '예: 소설, 에세이, 자기계발';

  @override
  String get category_select => '카테고리 선택 (선택사항)';

  @override
  String get category_noCategories => '아직 카테고리가 없어요';

  @override
  String get category_addHint => '카테고리를 추가해서 책을 정리해보세요';

  @override
  String get category_noBooksInCategory => '이 카테고리에 책이 없어요';

  @override
  String get category_addBookHint => '검색에서 책을 추가할 때 이 카테고리를 선택해보세요';

  @override
  String category_added(String name) {
    return '$name 카테고리가 추가되었습니다';
  }

  @override
  String get category_updated => '카테고리가 수정되었습니다';

  @override
  String category_deleted(String name) {
    return '$name 카테고리가 삭제되었습니다';
  }

  @override
  String category_deleteConfirm(String name) {
    return '$name 카테고리를 삭제하시겠습니까?';
  }

  @override
  String get category_loadFailed => '카테고리 로딩 실패';

  @override
  String get category_notFound => '카테고리를 찾을 수 없습니다';

  @override
  String get category_loadError => '카테고리를 불러올 수 없습니다';

  @override
  String get category_noList => '카테고리가 없습니다';

  @override
  String get category_noListHint => '카테고리가 없습니다.\n카테고리 탭에서 먼저 추가해주세요.';

  @override
  String get note_title => '노트';

  @override
  String get note_delete => '노트 삭제';

  @override
  String get note_deleteConfirm => '이 노트를 삭제하시겠습니까?';

  @override
  String get note_saved => '노트가 저장되었습니다';

  @override
  String get note_deleted => '노트가 삭제되었습니다';

  @override
  String get note_notFound => '노트를 찾을 수 없습니다';

  @override
  String get note_collect => '문장 수집';

  @override
  String get note_collectHint => '문장 수집 버튼을 눌러 문장을 수집해보세요';

  @override
  String get note_saveSentence => '문장 저장';

  @override
  String get note_original => '원문';

  @override
  String get note_aiSummary => 'AI 요약';

  @override
  String get note_aiSummarize => 'AI가 요약해드려요';

  @override
  String get note_memo => '내 메모';

  @override
  String get note_memoOptional => '메모 (선택)';

  @override
  String get note_memoPlaceholder => '이 문장에 대한 생각을 적어보세요...';

  @override
  String get note_memoSaved => '메모가 저장되었습니다';

  @override
  String get note_noMemo => '아직 메모가 없습니다. 수정 버튼을 눌러 메모를 추가해보세요.';

  @override
  String get note_pageNumber => '페이지 번호 (선택)';

  @override
  String get note_editContent => '본문을 수정하세요...';

  @override
  String get note_contentSaved => '본문이 저장되었습니다';

  @override
  String get note_tag => '태그';

  @override
  String get ocr_capture => '촬영';

  @override
  String get ocr_camera => '카메라';

  @override
  String get ocr_gallery => '갤러리';

  @override
  String get ocr_selectArea => '영역 선택';

  @override
  String get ocr_takePhoto => '문장을 촬영하세요';

  @override
  String get ocr_extracting => '텍스트 추출 중';

  @override
  String get ocr_extractedText => '추출된 텍스트';

  @override
  String get ocr_editExtracted => '추출된 텍스트를 수정하세요...';

  @override
  String get ocr_canEdit => '텍스트를 수정할 수 있습니다';

  @override
  String get ocr_summarize => '핵심만 쏙쏙 정리';

  @override
  String get ocr_processing => '이미지에서 텍스트를 인식하고 있습니다.\n잠시만 기다려주세요...';

  @override
  String get ocr_failed => 'OCR 처리에 실패했습니다';

  @override
  String get ocr_extractFailed => '텍스트 추출 실패';

  @override
  String get ocr_imageFailed => '이미지 처리에 실패했습니다';

  @override
  String get ocr_imageTooLarge => '이미지 크기가 너무 큽니다.\n다른 이미지를 선택해주세요';

  @override
  String get calendar_title => '캘린더';

  @override
  String calendar_yearActivity(int year) {
    return '$year년 독서 활동';
  }

  @override
  String calendar_dateCount(int month, int day, int count) {
    return '$month월 $day일: $count개';
  }

  @override
  String calendar_date(int month, int day) {
    return '$month월 $day일';
  }

  @override
  String get calendar_loadFailed => '캘린더를 불러오지 못했습니다';

  @override
  String get settings_title => '설정';

  @override
  String get settings_appInfo => '앱 정보';

  @override
  String get settings_display => '화면';

  @override
  String get settings_theme_light => '라이트 모드';

  @override
  String get settings_theme_lightDesc => '밝은 테마 사용';

  @override
  String get settings_theme_dark => '다크 모드';

  @override
  String get settings_theme_darkDesc => '어두운 테마 사용';

  @override
  String get settings_theme_system => '시스템 설정';

  @override
  String get settings_theme_systemDesc => '기기 설정에 따라 자동 전환';

  @override
  String get settings_language => '언어';

  @override
  String get settings_language_korean => '한국어';

  @override
  String get settings_language_koreanDesc => '한국어로 표시';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_englishDesc => '영어로 표시';

  @override
  String get error_generic => '오류가 발생했습니다';

  @override
  String error_genericWithDetail(String error) {
    return '오류: $error';
  }

  @override
  String get error_tryAgain => '오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get error_tryAgainLater => '잠시 후 다시 시도해주세요.';

  @override
  String get error_loadFailed => '불러오기 실패';

  @override
  String get error_loadFailedMessage => '불러오기에 실패했어요';

  @override
  String get error_network => '네트워크 연결을 확인해주세요';

  @override
  String get error_networkWithPeriod => '네트워크 연결을 확인해주세요.';

  @override
  String get error_timeout => '요청 시간이 초과되었습니다.\n네트워크 상태를 확인해주세요';

  @override
  String get error_tooManyRequests => '요청이 너무 많습니다.\n잠시 후 다시 시도해주세요';

  @override
  String get error_serverError => '서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요';

  @override
  String get error_temporaryError => '일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요';

  @override
  String get error_noPermission => '접근 권한이 없습니다';

  @override
  String get dateFormat_full => 'yyyy년 MM월 dd일 HH:mm';
}
