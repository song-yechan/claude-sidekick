import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/category_detail_screen.dart';
import '../screens/book/book_detail_screen.dart';
import '../screens/note/note_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/layout/main_layout.dart';

/// 라우터 리프레시 알림 클래스
///
/// auth/onboarding 상태 변화 시 GoRouter의 redirect를 재평가하도록 알립니다.
/// GoRouter 인스턴스는 유지하면서 redirect만 재실행되어 백그라운드 복귀 시 안정적입니다.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }
}

/// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // ref.read 사용 (watch 대신) - GoRouter 인스턴스 재생성 방지
      final authState = ref.read(authProvider);
      final onboardingState = ref.read(onboardingProvider);

      final isAuthenticated = authState.isAuthenticated;
      final isSplashPage = state.matchedLocation == '/splash';
      final isAuthPage = state.matchedLocation == '/auth';
      final isOnboardingPage = state.matchedLocation == '/onboarding';
      final isOnboardingPreview = state.matchedLocation.startsWith('/onboarding/preview');
      final isOnboardingCompleted = onboardingState.isCompleted;

      // 스플래시 화면은 자체적으로 네비게이션 처리 (리다이렉트 안함)
      if (isSplashPage) return null;

      // /home으로 오면 /로 리다이렉트
      if (state.matchedLocation == '/home') return '/';

      // 인증 로딩 중이면 리다이렉트 안함 (온보딩 로딩은 무시)
      if (authState.isLoading) {
        return null;
      }

      // 온보딩 미리보기는 항상 허용
      if (isOnboardingPreview) return null;

      // 인증 안됐으면 로그인 페이지로
      if (!isAuthenticated && !isAuthPage) {
        return '/auth';
      }

      // 인증됐는데 로그인 페이지면
      if (isAuthenticated && isAuthPage) {
        // 온보딩 안했으면 온보딩으로
        if (!isOnboardingCompleted) {
          return '/onboarding';
        }
        return '/';
      }

      // 인증됐고, 온보딩 안했고, 온보딩 페이지가 아니면 온보딩으로
      // (온보딩 로딩 중이면 일단 홈으로 보내고, 나중에 리다이렉트)
      if (isAuthenticated && !onboardingState.isLoading && !isOnboardingCompleted && !isOnboardingPage && !isOnboardingPreview) {
        return '/onboarding';
      }

      // 온보딩 완료했는데 온보딩 메인 페이지면 홈으로 (미리보기는 제외)
      if (isAuthenticated && isOnboardingCompleted && isOnboardingPage) {
        return '/';
      }

      return null;
    },
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 인증 화면
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // 온보딩 화면 (인터랙티브형 - Variant 2)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingVariant2(),
      ),

      // 메인 레이아웃 (하단 네비게이션 포함)
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
        ],
      ),

      // 상세 화면들 (하단 네비게이션 없음)
      GoRoute(
        path: '/categories/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CategoryDetailScreen(categoryId: id);
        },
      ),
      GoRoute(
        path: '/books/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookDetailScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NoteDetailScreen(noteId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
