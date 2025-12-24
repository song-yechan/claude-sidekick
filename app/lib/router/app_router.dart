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
import '../widgets/layout/main_layout.dart';

/// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPage = state.matchedLocation == '/auth';
      final isOnboardingPage = state.matchedLocation == '/onboarding';
      final isOnboardingPreview = state.matchedLocation.startsWith('/onboarding/preview');
      final isOnboardingCompleted = onboardingState.isCompleted;

      print('🔀 Router - location: ${state.matchedLocation}');
      print('🔀 Router - isAuthenticated: $isAuthenticated, isOnboardingCompleted: $isOnboardingCompleted');
      print('🔀 Router - authLoading: ${authState.isLoading}, onboardingLoading: ${onboardingState.isLoading}');

      // 인증 로딩 중이면 리다이렉트 안함 (온보딩 로딩은 무시)
      if (authState.isLoading) {
        print('🔀 Router - auth loading, no redirect');
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
