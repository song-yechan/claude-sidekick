// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BookScribe';

  @override
  String get common_confirm => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_save => 'Save';

  @override
  String get common_saving => 'Save';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_done => 'Done';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_add => 'Add';

  @override
  String get common_preview => 'Preview';

  @override
  String get common_start => 'Get Started';

  @override
  String get common_startNow => 'Start Now';

  @override
  String get common_preparing => 'Preparing...';

  @override
  String get common_version => 'Version';

  @override
  String get auth_login => 'Log In';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get auth_signUp => 'Sign Up';

  @override
  String get auth_signUpButton => 'Sign Up';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_passwordConfirm => 'Confirm Password';

  @override
  String get auth_emailPlaceholder => 'Enter your email';

  @override
  String get auth_passwordPlaceholder => 'Enter your password';

  @override
  String get auth_passwordConfirmPlaceholder => 'Re-enter your password';

  @override
  String get auth_noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get auth_hasAccount => 'Already have an account? Log In';

  @override
  String get auth_loginRequired => 'Login Required';

  @override
  String get auth_loginRequiredMessage => 'Please log in to continue';

  @override
  String get auth_logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get auth_welcomeBack => 'Welcome back!';

  @override
  String get auth_welcome => 'Welcome!';

  @override
  String get auth_welcomeWithEmoji => 'Welcome! 👋';

  @override
  String get auth_simpleSignUp => 'Get started with a simple sign up';

  @override
  String get auth_quickStart => 'Takes only 30 seconds';

  @override
  String get auth_error_invalidEmail => 'Please enter a valid email';

  @override
  String get auth_error_invalidEmailWithPeriod => 'Please enter a valid email.';

  @override
  String get auth_error_passwordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get auth_error_passwordTooShortWithPeriod =>
      'Password must be at least 6 characters.';

  @override
  String get auth_error_passwordMismatch => 'Passwords do not match';

  @override
  String get auth_error_minLength => 'Must be at least 6 characters';

  @override
  String get auth_error_loginFailed => 'Login failed.';

  @override
  String get auth_error_signUpFailed => 'Sign up failed.';

  @override
  String get auth_error_wrongCredentials => 'Invalid email or password.';

  @override
  String get auth_error_emailExists => 'This email is already registered.';

  @override
  String get auth_error_emailVerification => 'Email verification required.';

  @override
  String get account_title => 'Account';

  @override
  String get account_info => 'Account Info';

  @override
  String get account_loggedIn => 'Logged in as';

  @override
  String get account_delete => 'Delete Account';

  @override
  String get account_deleteConfirm =>
      'Deleting your account will permanently remove:';

  @override
  String get account_deleteWarning => 'All data will be permanently deleted';

  @override
  String get account_deleteIrreversible => 'This action cannot be undone.';

  @override
  String get account_deleting => 'Deleting account...';

  @override
  String get account_deleteFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get onboarding_selectStyle => 'Select onboarding style';

  @override
  String get onboarding_styleSelection => 'Onboarding Style';

  @override
  String get onboarding_previewSelected => 'Preview selected style';

  @override
  String get onboarding_selectFromThree =>
      'Choose from 3 different styles to preview';

  @override
  String get onboarding_style1Title => 'Style 1: Benefit-focused';

  @override
  String get onboarding_style1Desc =>
      'Calm, Blinkist style\nSlide-based feature introduction';

  @override
  String get onboarding_style2Title => 'Style 2: Interactive';

  @override
  String get onboarding_style2Desc =>
      'Spotify, Duolingo style\nPersonalized experience based on goals';

  @override
  String get onboarding_style3Title => 'Style 3: Minimal Quick-start';

  @override
  String get onboarding_style3Desc =>
      'Loom style\nSingle page with essential info only';

  @override
  String get onboarding_hello => 'Hello';

  @override
  String get onboarding_customExperience =>
      'Let us personalize your experience';

  @override
  String get onboarding_whatDoYouWant =>
      'What do you want to do\nwith BookScribe?';

  @override
  String get onboarding_multiSelect => 'You can select multiple options';

  @override
  String get onboarding_collectSentences => 'Collect favorite quotes';

  @override
  String get onboarding_keepRecord => 'Keep reading records';

  @override
  String get onboarding_rememberContent => 'Remember what I read';

  @override
  String get onboarding_buildHabit => 'Build a reading habit';

  @override
  String get onboarding_howOften => 'How often\ndo you read?';

  @override
  String get onboarding_freqHigh => 'A lot';

  @override
  String get onboarding_freqMedium => '2-3 times a week';

  @override
  String get onboarding_freqLow => 'Rarely';

  @override
  String get onboarding_freqOccasional => 'When I have time';

  @override
  String get onboarding_benefit_title1 => 'Collect your favorite quotes';

  @override
  String get onboarding_benefit_desc1 =>
      'Capture your favorite sentences\nwith your camera';

  @override
  String get onboarding_benefit_title2 => 'Photo to text instantly';

  @override
  String get onboarding_benefit_desc2 =>
      'Automatic text recognition\nwith AI-powered summarization';

  @override
  String get onboarding_benefit_title3 => 'Build your reading habit';

  @override
  String get onboarding_benefit_desc3 =>
      'Track your daily reading\nand create your own calendar';

  @override
  String get onboarding_benefit_title4 => 'Your personal reading journal';

  @override
  String get onboarding_benefit_desc4 =>
      'Start collecting your favorite\nquotes with BookScribe';

  @override
  String get onboarding_minimal_headline =>
      'Turn book quotes into your records';

  @override
  String get onboarding_minimal_subhead =>
      'The smartest way to capture book quotes';

  @override
  String get onboarding_minimal_cta =>
      'Start your enriched reading journey\nwith BookScribe';

  @override
  String get onboarding_habit_title => 'Consistency is key';

  @override
  String get onboarding_habit_daily => 'A little every day';

  @override
  String get onboarding_habit_10min => 'Just 10 minutes a day';

  @override
  String get onboarding_habit_noStress => 'No pressure, just enjoy';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_search => 'Search';

  @override
  String get nav_library => 'Library';

  @override
  String get nav_categories => 'Categories';

  @override
  String get home_recentNotes => 'Recent quotes';

  @override
  String get home_noNotes => 'No quotes collected yet';

  @override
  String get home_addBook => 'Add a book and save your favorite quotes';

  @override
  String get search_title => 'Search Books';

  @override
  String get search_searchBooks => 'Search Books';

  @override
  String get search_placeholder => 'Search by title, author, or ISBN';

  @override
  String get search_hint => 'Search by title, author, or ISBN';

  @override
  String get search_try => 'Try searching for a book';

  @override
  String get search_failed => 'Search failed';

  @override
  String get search_addToLibrary => 'Add to Library';

  @override
  String get library_title => 'My Library';

  @override
  String get library_noBooks => 'No books yet';

  @override
  String get library_addFromSearch => 'Add books from the Search tab';

  @override
  String get library_allBooks => 'All registered books';

  @override
  String get library_registeredBooks => 'Registered books';

  @override
  String get library_allNotes => 'All collected quotes';

  @override
  String get library_collectedNotes => 'Collected quotes';

  @override
  String library_bookCount(int count) {
    return '$count books';
  }

  @override
  String get book_delete => 'Delete Book';

  @override
  String book_deleteConfirm(String title) {
    return 'Delete $title?\nAll notes will also be deleted.';
  }

  @override
  String book_added(String title) {
    return '$title has been added';
  }

  @override
  String get book_deleted => 'Book deleted';

  @override
  String get book_addFailed => 'Failed to add book';

  @override
  String get book_notFound => 'Book not found';

  @override
  String get book_alreadyExists => 'Already registered';

  @override
  String get book_alreadyInLibrary => 'This book is already in your library.';

  @override
  String get book_addAnyway => 'Add anyway';

  @override
  String get book_addAnywayConfirm => 'Add anyway?';

  @override
  String get category_title => 'Categories';

  @override
  String get category_new => 'New Category';

  @override
  String get category_add => 'Add Category';

  @override
  String get category_edit => 'Edit Category';

  @override
  String get category_delete => 'Delete Category';

  @override
  String get category_name => 'Category name';

  @override
  String get category_namePlaceholder => 'e.g., Fiction, Essays, Self-help';

  @override
  String get category_select => 'Select category (optional)';

  @override
  String get category_noCategories => 'No categories yet';

  @override
  String get category_addHint => 'Add categories to organize your books';

  @override
  String get category_noBooksInCategory => 'No books in this category';

  @override
  String get category_addBookHint =>
      'Select this category when adding books from Search';

  @override
  String category_added(String name) {
    return '$name category added';
  }

  @override
  String get category_updated => 'Category updated';

  @override
  String category_deleted(String name) {
    return '$name category deleted';
  }

  @override
  String category_deleteConfirm(String name) {
    return 'Delete $name category?';
  }

  @override
  String get category_loadFailed => 'Failed to load categories';

  @override
  String get category_notFound => 'Category not found';

  @override
  String get category_loadError => 'Cannot load categories';

  @override
  String get category_noList => 'No categories';

  @override
  String get category_noListHint =>
      'No categories.\nAdd one from the Categories tab first.';

  @override
  String get note_title => 'Notes';

  @override
  String get note_delete => 'Delete Note';

  @override
  String get note_deleteConfirm => 'Delete this note?';

  @override
  String get note_saved => 'Note saved';

  @override
  String get note_deleted => 'Note deleted';

  @override
  String get note_notFound => 'Note not found';

  @override
  String get note_collect => 'Collect Quote';

  @override
  String get note_collectHint => 'Tap the collect button to save a quote';

  @override
  String get note_saveSentence => 'Save Quote';

  @override
  String get note_original => 'Original';

  @override
  String get note_aiSummary => 'AI Summary';

  @override
  String get note_aiSummarize => 'AI will summarize for you';

  @override
  String get note_memo => 'My Memo';

  @override
  String get note_memoOptional => 'Memo (optional)';

  @override
  String get note_memoPlaceholder => 'Write your thoughts about this quote...';

  @override
  String get note_memoSaved => 'Memo saved';

  @override
  String get note_noMemo => 'No memo yet. Tap edit to add one.';

  @override
  String get note_pageNumber => 'Page number (optional)';

  @override
  String get note_editContent => 'Edit content...';

  @override
  String get note_contentSaved => 'Content saved';

  @override
  String get note_tag => 'Tags';

  @override
  String get ocr_capture => 'Capture';

  @override
  String get ocr_camera => 'Camera';

  @override
  String get ocr_gallery => 'Gallery';

  @override
  String get ocr_selectArea => 'Select Area';

  @override
  String get ocr_takePhoto => 'Take a photo of the text';

  @override
  String get ocr_extracting => 'Extracting text';

  @override
  String get ocr_extractedText => 'Extracted text';

  @override
  String get ocr_editExtracted => 'Edit extracted text...';

  @override
  String get ocr_canEdit => 'You can edit the text';

  @override
  String get ocr_summarize => 'Get the key points';

  @override
  String get ocr_processing => 'Recognizing text from image.\nPlease wait...';

  @override
  String get ocr_failed => 'OCR processing failed';

  @override
  String get ocr_extractFailed => 'Text extraction failed';

  @override
  String get ocr_imageFailed => 'Image processing failed';

  @override
  String get ocr_imageTooLarge =>
      'Image is too large.\nPlease select a different image';

  @override
  String get calendar_title => 'Calendar';

  @override
  String calendar_yearActivity(int year) {
    return '$year Reading Activity';
  }

  @override
  String calendar_dateCount(int month, int day, int count) {
    return '$month/$day: $count notes';
  }

  @override
  String calendar_date(int month, int day) {
    return '$month/$day';
  }

  @override
  String get calendar_loadFailed => 'Failed to load calendar';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appInfo => 'App Info';

  @override
  String get settings_display => 'Display';

  @override
  String get settings_theme_light => 'Light Mode';

  @override
  String get settings_theme_lightDesc => 'Use light theme';

  @override
  String get settings_theme_dark => 'Dark Mode';

  @override
  String get settings_theme_darkDesc => 'Use dark theme';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_systemDesc => 'Follow system settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_korean => '한국어';

  @override
  String get settings_language_koreanDesc => 'Display in Korean';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_language_englishDesc => 'Display in English';

  @override
  String get error_generic => 'An error occurred';

  @override
  String error_genericWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get error_tryAgain => 'An error occurred. Please try again.';

  @override
  String get error_tryAgainLater => 'Please try again later.';

  @override
  String get error_loadFailed => 'Load failed';

  @override
  String get error_loadFailedMessage => 'Failed to load';

  @override
  String get error_network => 'Please check your network connection';

  @override
  String get error_networkWithPeriod => 'Please check your network connection.';

  @override
  String get error_timeout => 'Request timed out.\nPlease check your network';

  @override
  String get error_tooManyRequests =>
      'Too many requests.\nPlease try again later';

  @override
  String get error_serverError => 'Server error.\nPlease try again later';

  @override
  String get error_temporaryError => 'Temporary error.\nPlease try again later';

  @override
  String get error_noPermission => 'Access denied';

  @override
  String get dateFormat_full => 'MMM dd, yyyy HH:mm';

  @override
  String get streak_title => 'Reading Streak';

  @override
  String streak_currentDays(int days) {
    return '$days day streak';
  }

  @override
  String streak_longestRecord(int days) {
    return 'Longest: $days days';
  }

  @override
  String get streak_todayDone => 'Today\'s reading done!';

  @override
  String get streak_todayPending => 'Haven\'t read today yet';

  @override
  String get streak_startNew => 'Start a new streak';

  @override
  String get streak_keepGoing => 'Great job! Keep going';

  @override
  String get streak_almostThere => 'Almost there! Don\'t break your streak';

  @override
  String get streak_comeBack => 'Welcome back! Ready to start again?';

  @override
  String get notification_title => 'Notifications';

  @override
  String get notification_enable => 'Reading Reminders';

  @override
  String get notification_enableDesc => 'Get daily reading reminders';

  @override
  String get notification_time => 'Reminder Time';

  @override
  String get notification_timeDesc => 'When to receive reading reminders';

  @override
  String get notification_smartNudge => 'Smart Nudge';

  @override
  String get notification_smartNudgeDesc =>
      'Adjust reminder intensity based on activity';

  @override
  String get notification_permissionDenied => 'Notification permission denied';

  @override
  String get notification_goToSettings => 'Go to Settings';

  @override
  String get notification_title_reading_reminder => 'Reading Time';

  @override
  String get notification_message_normal => 'Time for your daily reading! 📚';

  @override
  String get notification_message_gentle =>
      'Missed yesterday? How about today?';

  @override
  String notification_message_moderate(int days) {
    return 'Keep your $days-day streak going!';
  }

  @override
  String get notification_message_strong =>
      'Your books miss you. Ready to start again?';

  @override
  String get settings_notification => 'Notification Settings';

  @override
  String get onboarding_notification_title => 'Get reading reminders';

  @override
  String get onboarding_notification_subtitle =>
      'We\'ll send you a daily reminder at your chosen time';

  @override
  String get onboarding_notification_timeLabel => 'Reminder time';

  @override
  String get onboarding_notification_skipHint =>
      'You can change this later in Settings';
}
