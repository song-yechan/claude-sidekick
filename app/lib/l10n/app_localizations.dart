import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'북스크라이브'**
  String get appName;

  /// No description provided for @common_confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get common_confirm;

  /// No description provided for @common_cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get common_delete;

  /// No description provided for @common_save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get common_save;

  /// No description provided for @common_saving.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get common_saving;

  /// No description provided for @common_edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get common_edit;

  /// No description provided for @common_next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get common_skip;

  /// No description provided for @common_done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get common_done;

  /// No description provided for @common_retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get common_retry;

  /// No description provided for @common_add.
  ///
  /// In ko, this message translates to:
  /// **'추가하기'**
  String get common_add;

  /// No description provided for @common_preview.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get common_preview;

  /// No description provided for @common_start.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get common_start;

  /// No description provided for @common_startNow.
  ///
  /// In ko, this message translates to:
  /// **'바로 시작하기'**
  String get common_startNow;

  /// No description provided for @common_preparing.
  ///
  /// In ko, this message translates to:
  /// **'준비 중...'**
  String get common_preparing;

  /// No description provided for @common_version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get common_version;

  /// No description provided for @auth_login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get auth_login;

  /// No description provided for @auth_logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get auth_logout;

  /// No description provided for @auth_signUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get auth_signUp;

  /// No description provided for @auth_signUpButton.
  ///
  /// In ko, this message translates to:
  /// **'가입하기'**
  String get auth_signUpButton;

  /// No description provided for @auth_email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get auth_password;

  /// No description provided for @auth_passwordConfirm.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get auth_passwordConfirm;

  /// No description provided for @auth_emailPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력해주세요'**
  String get auth_emailPlaceholder;

  /// No description provided for @auth_passwordPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력해주세요'**
  String get auth_passwordPlaceholder;

  /// No description provided for @auth_passwordConfirmPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 다시 입력해주세요'**
  String get auth_passwordConfirmPlaceholder;

  /// No description provided for @auth_noAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정이 없으신가요? 회원가입'**
  String get auth_noAccount;

  /// No description provided for @auth_hasAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요? 로그인'**
  String get auth_hasAccount;

  /// No description provided for @auth_loginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인 필요'**
  String get auth_loginRequired;

  /// No description provided for @auth_loginRequiredMessage.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다'**
  String get auth_loginRequiredMessage;

  /// No description provided for @auth_logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠습니까?'**
  String get auth_logoutConfirm;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In ko, this message translates to:
  /// **'다시 만나서 반가워요'**
  String get auth_welcomeBack;

  /// No description provided for @auth_welcome.
  ///
  /// In ko, this message translates to:
  /// **'환영합니다!'**
  String get auth_welcome;

  /// No description provided for @auth_welcomeWithEmoji.
  ///
  /// In ko, this message translates to:
  /// **'환영합니다! 👋'**
  String get auth_welcomeWithEmoji;

  /// No description provided for @auth_simpleSignUp.
  ///
  /// In ko, this message translates to:
  /// **'간단한 가입으로 시작하세요'**
  String get auth_simpleSignUp;

  /// No description provided for @auth_quickStart.
  ///
  /// In ko, this message translates to:
  /// **'30초면 시작할 수 있어요'**
  String get auth_quickStart;

  /// No description provided for @auth_error_invalidEmail.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다'**
  String get auth_error_invalidEmail;

  /// No description provided for @auth_error_invalidEmailWithPeriod.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다.'**
  String get auth_error_invalidEmailWithPeriod;

  /// No description provided for @auth_error_passwordTooShort.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다'**
  String get auth_error_passwordTooShort;

  /// No description provided for @auth_error_passwordTooShortWithPeriod.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다.'**
  String get auth_error_passwordTooShortWithPeriod;

  /// No description provided for @auth_error_passwordMismatch.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 일치하지 않습니다'**
  String get auth_error_passwordMismatch;

  /// No description provided for @auth_error_minLength.
  ///
  /// In ko, this message translates to:
  /// **'6자 이상 입력해주세요'**
  String get auth_error_minLength;

  /// No description provided for @auth_error_loginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다.'**
  String get auth_error_loginFailed;

  /// No description provided for @auth_error_signUpFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다.'**
  String get auth_error_signUpFailed;

  /// No description provided for @auth_error_wrongCredentials.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않습니다.'**
  String get auth_error_wrongCredentials;

  /// No description provided for @auth_error_emailExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 가입된 이메일입니다.'**
  String get auth_error_emailExists;

  /// No description provided for @auth_error_emailVerification.
  ///
  /// In ko, this message translates to:
  /// **'이메일 인증이 필요합니다.'**
  String get auth_error_emailVerification;

  /// No description provided for @account_title.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account_title;

  /// No description provided for @account_info.
  ///
  /// In ko, this message translates to:
  /// **'계정 정보'**
  String get account_info;

  /// No description provided for @account_loggedIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인된 계정'**
  String get account_loggedIn;

  /// No description provided for @account_delete.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get account_delete;

  /// No description provided for @account_deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제하면 다음 데이터가 영구적으로 삭제됩니다:'**
  String get account_deleteConfirm;

  /// No description provided for @account_deleteWarning.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터가 영구적으로 삭제됩니다'**
  String get account_deleteWarning;

  /// No description provided for @account_deleteIrreversible.
  ///
  /// In ko, this message translates to:
  /// **'이 작업은 되돌릴 수 없습니다.'**
  String get account_deleteIrreversible;

  /// No description provided for @account_deleting.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제하는 중...'**
  String get account_deleting;

  /// No description provided for @account_deleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제에 실패했습니다. 다시 시도해주세요.'**
  String get account_deleteFailed;

  /// No description provided for @onboarding_selectStyle.
  ///
  /// In ko, this message translates to:
  /// **'온보딩 스타일을 선택하세요'**
  String get onboarding_selectStyle;

  /// No description provided for @onboarding_styleSelection.
  ///
  /// In ko, this message translates to:
  /// **'온보딩 시안 선택'**
  String get onboarding_styleSelection;

  /// No description provided for @onboarding_previewSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택한 시안 미리보기'**
  String get onboarding_previewSelected;

  /// No description provided for @onboarding_selectFromThree.
  ///
  /// In ko, this message translates to:
  /// **'3가지 시안 중 하나를 선택하여 미리볼 수 있습니다'**
  String get onboarding_selectFromThree;

  /// No description provided for @onboarding_style1Title.
  ///
  /// In ko, this message translates to:
  /// **'시안 1: 혜택 중심형'**
  String get onboarding_style1Title;

  /// No description provided for @onboarding_style1Desc.
  ///
  /// In ko, this message translates to:
  /// **'Calm, Blinkist 스타일\n슬라이드로 주요 기능과 혜택 소개'**
  String get onboarding_style1Desc;

  /// No description provided for @onboarding_style2Title.
  ///
  /// In ko, this message translates to:
  /// **'시안 2: 인터랙티브형'**
  String get onboarding_style2Title;

  /// No description provided for @onboarding_style2Desc.
  ///
  /// In ko, this message translates to:
  /// **'Spotify, Duolingo 스타일\n사용자 목표를 묻고 개인화된 경험 제공'**
  String get onboarding_style2Desc;

  /// No description provided for @onboarding_style3Title.
  ///
  /// In ko, this message translates to:
  /// **'시안 3: 미니멀 빠른시작'**
  String get onboarding_style3Title;

  /// No description provided for @onboarding_style3Desc.
  ///
  /// In ko, this message translates to:
  /// **'Loom 스타일\n단일 페이지로 핵심만 빠르게 전달'**
  String get onboarding_style3Desc;

  /// No description provided for @onboarding_hello.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요'**
  String get onboarding_hello;

  /// No description provided for @onboarding_customExperience.
  ///
  /// In ko, this message translates to:
  /// **'맞춤 경험을 제공해드릴게요'**
  String get onboarding_customExperience;

  /// No description provided for @onboarding_whatDoYouWant.
  ///
  /// In ko, this message translates to:
  /// **'북스크라이브를 통해\n무엇을 하고 싶으세요?'**
  String get onboarding_whatDoYouWant;

  /// No description provided for @onboarding_multiSelect.
  ///
  /// In ko, this message translates to:
  /// **'여러 개를 선택할 수 있어요'**
  String get onboarding_multiSelect;

  /// No description provided for @onboarding_collectSentences.
  ///
  /// In ko, this message translates to:
  /// **'좋은 문장 수집하기'**
  String get onboarding_collectSentences;

  /// No description provided for @onboarding_keepRecord.
  ///
  /// In ko, this message translates to:
  /// **'독서 기록 남기기'**
  String get onboarding_keepRecord;

  /// No description provided for @onboarding_rememberContent.
  ///
  /// In ko, this message translates to:
  /// **'읽은 내용 기억하기'**
  String get onboarding_rememberContent;

  /// No description provided for @onboarding_buildHabit.
  ///
  /// In ko, this message translates to:
  /// **'독서 습관 만들기'**
  String get onboarding_buildHabit;

  /// No description provided for @onboarding_howOften.
  ///
  /// In ko, this message translates to:
  /// **'얼마나 자주\n책을 읽으시나요?'**
  String get onboarding_howOften;

  /// No description provided for @onboarding_freqHigh.
  ///
  /// In ko, this message translates to:
  /// **'많음'**
  String get onboarding_freqHigh;

  /// No description provided for @onboarding_freqMedium.
  ///
  /// In ko, this message translates to:
  /// **'주 2-3회'**
  String get onboarding_freqMedium;

  /// No description provided for @onboarding_freqLow.
  ///
  /// In ko, this message translates to:
  /// **'적음'**
  String get onboarding_freqLow;

  /// No description provided for @onboarding_freqOccasional.
  ///
  /// In ko, this message translates to:
  /// **'여유 있을 때'**
  String get onboarding_freqOccasional;

  /// No description provided for @onboarding_benefit_title1.
  ///
  /// In ko, this message translates to:
  /// **'책 속 문장을 수집하세요'**
  String get onboarding_benefit_title1;

  /// No description provided for @onboarding_benefit_desc1.
  ///
  /// In ko, this message translates to:
  /// **'책 속 마음에 드는 문장을\n카메라로 간편하게 촬영하세요'**
  String get onboarding_benefit_desc1;

  /// No description provided for @onboarding_benefit_title2.
  ///
  /// In ko, this message translates to:
  /// **'문장을 찍으면 텍스트로 변환'**
  String get onboarding_benefit_title2;

  /// No description provided for @onboarding_benefit_desc2.
  ///
  /// In ko, this message translates to:
  /// **'촬영한 문장을 자동으로 인식하고\nAI가 핵심만 요약해드립니다'**
  String get onboarding_benefit_desc2;

  /// No description provided for @onboarding_benefit_title3.
  ///
  /// In ko, this message translates to:
  /// **'독서 습관을 만드세요'**
  String get onboarding_benefit_title3;

  /// No description provided for @onboarding_benefit_desc3.
  ///
  /// In ko, this message translates to:
  /// **'매일의 독서 기록이 쌓여\n나만의 독서 캘린더가 완성됩니다'**
  String get onboarding_benefit_desc3;

  /// No description provided for @onboarding_benefit_title4.
  ///
  /// In ko, this message translates to:
  /// **'나만의 독서 기록'**
  String get onboarding_benefit_title4;

  /// No description provided for @onboarding_benefit_desc4.
  ///
  /// In ko, this message translates to:
  /// **'이제 BookScribe와 함께\n책 속 문장을 수집해보세요'**
  String get onboarding_benefit_desc4;

  /// No description provided for @onboarding_minimal_headline.
  ///
  /// In ko, this message translates to:
  /// **'책 속 문장을 나만의 기록으로'**
  String get onboarding_minimal_headline;

  /// No description provided for @onboarding_minimal_subhead.
  ///
  /// In ko, this message translates to:
  /// **'책 속 문장을 기록하는 가장 스마트한 방법'**
  String get onboarding_minimal_subhead;

  /// No description provided for @onboarding_minimal_cta.
  ///
  /// In ko, this message translates to:
  /// **'북스크라이브와 함께\n더 풍요로운 독서 생활을 시작해보세요'**
  String get onboarding_minimal_cta;

  /// No description provided for @onboarding_habit_title.
  ///
  /// In ko, this message translates to:
  /// **'꾸준함이 중요해요'**
  String get onboarding_habit_title;

  /// No description provided for @onboarding_habit_daily.
  ///
  /// In ko, this message translates to:
  /// **'매일 조금씩'**
  String get onboarding_habit_daily;

  /// No description provided for @onboarding_habit_10min.
  ///
  /// In ko, this message translates to:
  /// **'하루 10분이면 충분해요'**
  String get onboarding_habit_10min;

  /// No description provided for @onboarding_habit_noStress.
  ///
  /// In ko, this message translates to:
  /// **'부담 없이 즐기세요'**
  String get onboarding_habit_noStress;

  /// No description provided for @nav_home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get nav_home;

  /// No description provided for @nav_search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get nav_search;

  /// No description provided for @nav_library.
  ///
  /// In ko, this message translates to:
  /// **'서재'**
  String get nav_library;

  /// No description provided for @nav_categories.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get nav_categories;

  /// No description provided for @home_recentNotes.
  ///
  /// In ko, this message translates to:
  /// **'최근 수집한 문장'**
  String get home_recentNotes;

  /// No description provided for @home_noNotes.
  ///
  /// In ko, this message translates to:
  /// **'아직 수집한 문장이 없어요'**
  String get home_noNotes;

  /// No description provided for @home_addBook.
  ///
  /// In ko, this message translates to:
  /// **'책을 등록하고 마음에 드는 문장을 저장해보세요'**
  String get home_addBook;

  /// No description provided for @search_title.
  ///
  /// In ko, this message translates to:
  /// **'책 검색'**
  String get search_title;

  /// No description provided for @search_searchBooks.
  ///
  /// In ko, this message translates to:
  /// **'책 검색하기'**
  String get search_searchBooks;

  /// No description provided for @search_placeholder.
  ///
  /// In ko, this message translates to:
  /// **'책 제목, 저자, ISBN으로 검색'**
  String get search_placeholder;

  /// No description provided for @search_hint.
  ///
  /// In ko, this message translates to:
  /// **'제목, 저자, ISBN으로 검색할 수 있어요'**
  String get search_hint;

  /// No description provided for @search_try.
  ///
  /// In ko, this message translates to:
  /// **'책을 검색해보세요'**
  String get search_try;

  /// No description provided for @search_failed.
  ///
  /// In ko, this message translates to:
  /// **'검색에 실패했어요'**
  String get search_failed;

  /// No description provided for @search_addToLibrary.
  ///
  /// In ko, this message translates to:
  /// **'서재에 추가'**
  String get search_addToLibrary;

  /// No description provided for @library_title.
  ///
  /// In ko, this message translates to:
  /// **'내 서재'**
  String get library_title;

  /// No description provided for @library_noBooks.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 책이 없어요'**
  String get library_noBooks;

  /// No description provided for @library_addFromSearch.
  ///
  /// In ko, this message translates to:
  /// **'검색 탭에서 책을 추가해보세요'**
  String get library_addFromSearch;

  /// No description provided for @library_allBooks.
  ///
  /// In ko, this message translates to:
  /// **'등록한 모든 책'**
  String get library_allBooks;

  /// No description provided for @library_registeredBooks.
  ///
  /// In ko, this message translates to:
  /// **'등록한 책'**
  String get library_registeredBooks;

  /// No description provided for @library_allNotes.
  ///
  /// In ko, this message translates to:
  /// **'수집한 모든 문장'**
  String get library_allNotes;

  /// No description provided for @library_collectedNotes.
  ///
  /// In ko, this message translates to:
  /// **'수집한 문장'**
  String get library_collectedNotes;

  /// No description provided for @library_bookCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}권'**
  String library_bookCount(int count);

  /// No description provided for @book_delete.
  ///
  /// In ko, this message translates to:
  /// **'책 삭제'**
  String get book_delete;

  /// No description provided for @book_deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{title}을(를) 삭제하시겠습니까?\n모든 노트도 함께 삭제됩니다.'**
  String book_deleteConfirm(String title);

  /// No description provided for @book_added.
  ///
  /// In ko, this message translates to:
  /// **'{title}이(가) 추가되었습니다'**
  String book_added(String title);

  /// No description provided for @book_deleted.
  ///
  /// In ko, this message translates to:
  /// **'책이 삭제되었습니다'**
  String get book_deleted;

  /// No description provided for @book_addFailed.
  ///
  /// In ko, this message translates to:
  /// **'책 추가에 실패했습니다'**
  String get book_addFailed;

  /// No description provided for @book_notFound.
  ///
  /// In ko, this message translates to:
  /// **'책을 찾을 수 없습니다'**
  String get book_notFound;

  /// No description provided for @book_alreadyExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 등록된 책'**
  String get book_alreadyExists;

  /// No description provided for @book_alreadyInLibrary.
  ///
  /// In ko, this message translates to:
  /// **'서재에 같은 책이 이미 있어요.'**
  String get book_alreadyInLibrary;

  /// No description provided for @book_addAnyway.
  ///
  /// In ko, this message translates to:
  /// **'그래도 추가'**
  String get book_addAnyway;

  /// No description provided for @book_addAnywayConfirm.
  ///
  /// In ko, this message translates to:
  /// **'그래도 추가하시겠어요?'**
  String get book_addAnywayConfirm;

  /// No description provided for @category_title.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get category_title;

  /// No description provided for @category_new.
  ///
  /// In ko, this message translates to:
  /// **'새 카테고리'**
  String get category_new;

  /// No description provided for @category_add.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 추가'**
  String get category_add;

  /// No description provided for @category_edit.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 수정'**
  String get category_edit;

  /// No description provided for @category_delete.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 삭제'**
  String get category_delete;

  /// No description provided for @category_name.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 이름'**
  String get category_name;

  /// No description provided for @category_namePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'예: 소설, 에세이, 자기계발'**
  String get category_namePlaceholder;

  /// No description provided for @category_select.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 선택 (선택사항)'**
  String get category_select;

  /// No description provided for @category_noCategories.
  ///
  /// In ko, this message translates to:
  /// **'아직 카테고리가 없어요'**
  String get category_noCategories;

  /// No description provided for @category_addHint.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 추가해서 책을 정리해보세요'**
  String get category_addHint;

  /// No description provided for @category_noBooksInCategory.
  ///
  /// In ko, this message translates to:
  /// **'이 카테고리에 책이 없어요'**
  String get category_noBooksInCategory;

  /// No description provided for @category_addBookHint.
  ///
  /// In ko, this message translates to:
  /// **'검색에서 책을 추가할 때 이 카테고리를 선택해보세요'**
  String get category_addBookHint;

  /// No description provided for @category_added.
  ///
  /// In ko, this message translates to:
  /// **'{name} 카테고리가 추가되었습니다'**
  String category_added(String name);

  /// No description provided for @category_updated.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 수정되었습니다'**
  String get category_updated;

  /// No description provided for @category_deleted.
  ///
  /// In ko, this message translates to:
  /// **'{name} 카테고리가 삭제되었습니다'**
  String category_deleted(String name);

  /// No description provided for @category_deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name} 카테고리를 삭제하시겠습니까?'**
  String category_deleteConfirm(String name);

  /// No description provided for @category_loadFailed.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 로딩 실패'**
  String get category_loadFailed;

  /// No description provided for @category_notFound.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 찾을 수 없습니다'**
  String get category_notFound;

  /// No description provided for @category_loadError.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 불러올 수 없습니다'**
  String get category_loadError;

  /// No description provided for @category_noList.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 없습니다'**
  String get category_noList;

  /// No description provided for @category_noListHint.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 없습니다.\n카테고리 탭에서 먼저 추가해주세요.'**
  String get category_noListHint;

  /// No description provided for @note_title.
  ///
  /// In ko, this message translates to:
  /// **'노트'**
  String get note_title;

  /// No description provided for @note_delete.
  ///
  /// In ko, this message translates to:
  /// **'노트 삭제'**
  String get note_delete;

  /// No description provided for @note_deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 노트를 삭제하시겠습니까?'**
  String get note_deleteConfirm;

  /// No description provided for @note_saved.
  ///
  /// In ko, this message translates to:
  /// **'노트가 저장되었습니다'**
  String get note_saved;

  /// No description provided for @note_deleted.
  ///
  /// In ko, this message translates to:
  /// **'노트가 삭제되었습니다'**
  String get note_deleted;

  /// No description provided for @note_notFound.
  ///
  /// In ko, this message translates to:
  /// **'노트를 찾을 수 없습니다'**
  String get note_notFound;

  /// No description provided for @note_collect.
  ///
  /// In ko, this message translates to:
  /// **'문장 수집'**
  String get note_collect;

  /// No description provided for @note_collectHint.
  ///
  /// In ko, this message translates to:
  /// **'문장 수집 버튼을 눌러 문장을 수집해보세요'**
  String get note_collectHint;

  /// No description provided for @note_saveSentence.
  ///
  /// In ko, this message translates to:
  /// **'문장 저장'**
  String get note_saveSentence;

  /// No description provided for @note_original.
  ///
  /// In ko, this message translates to:
  /// **'원문'**
  String get note_original;

  /// No description provided for @note_aiSummary.
  ///
  /// In ko, this message translates to:
  /// **'AI 요약'**
  String get note_aiSummary;

  /// No description provided for @note_aiSummarize.
  ///
  /// In ko, this message translates to:
  /// **'AI가 요약해드려요'**
  String get note_aiSummarize;

  /// No description provided for @note_memo.
  ///
  /// In ko, this message translates to:
  /// **'내 메모'**
  String get note_memo;

  /// No description provided for @note_memoOptional.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get note_memoOptional;

  /// No description provided for @note_memoPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'이 문장에 대한 생각을 적어보세요...'**
  String get note_memoPlaceholder;

  /// No description provided for @note_memoSaved.
  ///
  /// In ko, this message translates to:
  /// **'메모가 저장되었습니다'**
  String get note_memoSaved;

  /// No description provided for @note_noMemo.
  ///
  /// In ko, this message translates to:
  /// **'아직 메모가 없습니다. 수정 버튼을 눌러 메모를 추가해보세요.'**
  String get note_noMemo;

  /// No description provided for @note_pageNumber.
  ///
  /// In ko, this message translates to:
  /// **'페이지 번호 (선택)'**
  String get note_pageNumber;

  /// No description provided for @note_editContent.
  ///
  /// In ko, this message translates to:
  /// **'본문을 수정하세요...'**
  String get note_editContent;

  /// No description provided for @note_contentSaved.
  ///
  /// In ko, this message translates to:
  /// **'본문이 저장되었습니다'**
  String get note_contentSaved;

  /// No description provided for @note_tag.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get note_tag;

  /// No description provided for @ocr_capture.
  ///
  /// In ko, this message translates to:
  /// **'촬영'**
  String get ocr_capture;

  /// No description provided for @ocr_camera.
  ///
  /// In ko, this message translates to:
  /// **'카메라'**
  String get ocr_camera;

  /// No description provided for @ocr_gallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get ocr_gallery;

  /// No description provided for @ocr_selectArea.
  ///
  /// In ko, this message translates to:
  /// **'영역 선택'**
  String get ocr_selectArea;

  /// No description provided for @ocr_takePhoto.
  ///
  /// In ko, this message translates to:
  /// **'문장을 촬영하세요'**
  String get ocr_takePhoto;

  /// No description provided for @ocr_extracting.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 추출 중'**
  String get ocr_extracting;

  /// No description provided for @ocr_extractedText.
  ///
  /// In ko, this message translates to:
  /// **'추출된 텍스트'**
  String get ocr_extractedText;

  /// No description provided for @ocr_editExtracted.
  ///
  /// In ko, this message translates to:
  /// **'추출된 텍스트를 수정하세요...'**
  String get ocr_editExtracted;

  /// No description provided for @ocr_canEdit.
  ///
  /// In ko, this message translates to:
  /// **'텍스트를 수정할 수 있습니다'**
  String get ocr_canEdit;

  /// No description provided for @ocr_summarize.
  ///
  /// In ko, this message translates to:
  /// **'핵심만 쏙쏙 정리'**
  String get ocr_summarize;

  /// No description provided for @ocr_processing.
  ///
  /// In ko, this message translates to:
  /// **'이미지에서 텍스트를 인식하고 있습니다.\n잠시만 기다려주세요...'**
  String get ocr_processing;

  /// No description provided for @ocr_failed.
  ///
  /// In ko, this message translates to:
  /// **'OCR 처리에 실패했습니다'**
  String get ocr_failed;

  /// No description provided for @ocr_extractFailed.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 추출 실패'**
  String get ocr_extractFailed;

  /// No description provided for @ocr_imageFailed.
  ///
  /// In ko, this message translates to:
  /// **'이미지 처리에 실패했습니다'**
  String get ocr_imageFailed;

  /// No description provided for @ocr_imageTooLarge.
  ///
  /// In ko, this message translates to:
  /// **'이미지 크기가 너무 큽니다.\n다른 이미지를 선택해주세요'**
  String get ocr_imageTooLarge;

  /// No description provided for @calendar_title.
  ///
  /// In ko, this message translates to:
  /// **'캘린더'**
  String get calendar_title;

  /// No description provided for @calendar_yearActivity.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 독서 활동'**
  String calendar_yearActivity(int year);

  /// No description provided for @calendar_dateCount.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일: {count}개'**
  String calendar_dateCount(int month, int day, int count);

  /// No description provided for @calendar_date.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일'**
  String calendar_date(int month, int day);

  /// No description provided for @calendar_loadFailed.
  ///
  /// In ko, this message translates to:
  /// **'캘린더를 불러오지 못했습니다'**
  String get calendar_loadFailed;

  /// No description provided for @settings_title.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings_title;

  /// No description provided for @settings_appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settings_appInfo;

  /// No description provided for @settings_display.
  ///
  /// In ko, this message translates to:
  /// **'화면'**
  String get settings_display;

  /// No description provided for @settings_theme_light.
  ///
  /// In ko, this message translates to:
  /// **'라이트 모드'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_lightDesc.
  ///
  /// In ko, this message translates to:
  /// **'밝은 테마 사용'**
  String get settings_theme_lightDesc;

  /// No description provided for @settings_theme_dark.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_darkDesc.
  ///
  /// In ko, this message translates to:
  /// **'어두운 테마 사용'**
  String get settings_theme_darkDesc;

  /// No description provided for @settings_theme_system.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_systemDesc.
  ///
  /// In ko, this message translates to:
  /// **'기기 설정에 따라 자동 전환'**
  String get settings_theme_systemDesc;

  /// No description provided for @settings_language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settings_language;

  /// No description provided for @settings_language_korean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settings_language_korean;

  /// No description provided for @settings_language_koreanDesc.
  ///
  /// In ko, this message translates to:
  /// **'한국어로 표시'**
  String get settings_language_koreanDesc;

  /// No description provided for @settings_language_english.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_language_englishDesc.
  ///
  /// In ko, this message translates to:
  /// **'영어로 표시'**
  String get settings_language_englishDesc;

  /// No description provided for @error_generic.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get error_generic;

  /// No description provided for @error_genericWithDetail.
  ///
  /// In ko, this message translates to:
  /// **'오류: {error}'**
  String error_genericWithDetail(String error);

  /// No description provided for @error_tryAgain.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다. 다시 시도해주세요.'**
  String get error_tryAgain;

  /// No description provided for @error_tryAgainLater.
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도해주세요.'**
  String get error_tryAgainLater;

  /// No description provided for @error_loadFailed.
  ///
  /// In ko, this message translates to:
  /// **'불러오기 실패'**
  String get error_loadFailed;

  /// No description provided for @error_loadFailedMessage.
  ///
  /// In ko, this message translates to:
  /// **'불러오기에 실패했어요'**
  String get error_loadFailedMessage;

  /// No description provided for @error_network.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요'**
  String get error_network;

  /// No description provided for @error_networkWithPeriod.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요.'**
  String get error_networkWithPeriod;

  /// No description provided for @error_timeout.
  ///
  /// In ko, this message translates to:
  /// **'요청 시간이 초과되었습니다.\n네트워크 상태를 확인해주세요'**
  String get error_timeout;

  /// No description provided for @error_tooManyRequests.
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 많습니다.\n잠시 후 다시 시도해주세요'**
  String get error_tooManyRequests;

  /// No description provided for @error_serverError.
  ///
  /// In ko, this message translates to:
  /// **'서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요'**
  String get error_serverError;

  /// No description provided for @error_temporaryError.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요'**
  String get error_temporaryError;

  /// No description provided for @error_noPermission.
  ///
  /// In ko, this message translates to:
  /// **'접근 권한이 없습니다'**
  String get error_noPermission;

  /// No description provided for @dateFormat_full.
  ///
  /// In ko, this message translates to:
  /// **'yyyy년 MM월 dd일 HH:mm'**
  String get dateFormat_full;

  /// No description provided for @streak_title.
  ///
  /// In ko, this message translates to:
  /// **'연속 독서'**
  String get streak_title;

  /// No description provided for @streak_currentDays.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 연속'**
  String streak_currentDays(int days);

  /// No description provided for @streak_longestRecord.
  ///
  /// In ko, this message translates to:
  /// **'최장 기록: {days}일'**
  String streak_longestRecord(int days);

  /// No description provided for @streak_todayDone.
  ///
  /// In ko, this message translates to:
  /// **'오늘 독서 완료!'**
  String get streak_todayDone;

  /// No description provided for @streak_todayPending.
  ///
  /// In ko, this message translates to:
  /// **'오늘 아직 독서하지 않았어요'**
  String get streak_todayPending;

  /// No description provided for @streak_startNew.
  ///
  /// In ko, this message translates to:
  /// **'새로운 연속 기록을 시작해보세요'**
  String get streak_startNew;

  /// No description provided for @streak_keepGoing.
  ///
  /// In ko, this message translates to:
  /// **'잘하고 있어요! 계속해보세요'**
  String get streak_keepGoing;

  /// No description provided for @streak_almostThere.
  ///
  /// In ko, this message translates to:
  /// **'조금만 더! 스트릭을 이어가세요'**
  String get streak_almostThere;

  /// No description provided for @streak_comeBack.
  ///
  /// In ko, this message translates to:
  /// **'돌아오셨군요! 다시 시작해볼까요?'**
  String get streak_comeBack;

  /// No description provided for @notification_title.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notification_title;

  /// No description provided for @notification_enable.
  ///
  /// In ko, this message translates to:
  /// **'독서 알림'**
  String get notification_enable;

  /// No description provided for @notification_enableDesc.
  ///
  /// In ko, this message translates to:
  /// **'매일 독서 리마인더를 받습니다'**
  String get notification_enableDesc;

  /// No description provided for @notification_time.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간'**
  String get notification_time;

  /// No description provided for @notification_timeDesc.
  ///
  /// In ko, this message translates to:
  /// **'독서 알림을 받을 시간'**
  String get notification_timeDesc;

  /// No description provided for @notification_smartNudge.
  ///
  /// In ko, this message translates to:
  /// **'스마트 넛지'**
  String get notification_smartNudge;

  /// No description provided for @notification_smartNudgeDesc.
  ///
  /// In ko, this message translates to:
  /// **'비활성 기간에 따라 알림 강도 조정'**
  String get notification_smartNudgeDesc;

  /// No description provided for @notification_permissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 거부되었습니다'**
  String get notification_permissionDenied;

  /// No description provided for @notification_goToSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get notification_goToSettings;

  /// No description provided for @notification_title_reading_reminder.
  ///
  /// In ko, this message translates to:
  /// **'독서 시간'**
  String get notification_title_reading_reminder;

  /// No description provided for @notification_message_normal.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 독서 시간이에요! 📚'**
  String get notification_message_normal;

  /// No description provided for @notification_message_gentle.
  ///
  /// In ko, this message translates to:
  /// **'어제 못 읽었죠? 오늘은 어때요?'**
  String get notification_message_gentle;

  /// No description provided for @notification_message_moderate.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 연속 기록을 이어가세요!'**
  String notification_message_moderate(int days);

  /// No description provided for @notification_message_strong.
  ///
  /// In ko, this message translates to:
  /// **'책이 기다리고 있어요. 다시 시작해볼까요?'**
  String get notification_message_strong;

  /// No description provided for @settings_notification.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get settings_notification;

  /// No description provided for @onboarding_notification_title.
  ///
  /// In ko, this message translates to:
  /// **'독서 알림을 받아보세요'**
  String get onboarding_notification_title;

  /// No description provided for @onboarding_notification_subtitle.
  ///
  /// In ko, this message translates to:
  /// **'매일 같은 시간에 독서 리마인더를 보내드릴게요'**
  String get onboarding_notification_subtitle;

  /// No description provided for @onboarding_notification_timeLabel.
  ///
  /// In ko, this message translates to:
  /// **'알림 받을 시간'**
  String get onboarding_notification_timeLabel;

  /// No description provided for @onboarding_notification_skipHint.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정에서 변경할 수 있어요'**
  String get onboarding_notification_skipHint;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ko':
      return L10nKo();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
