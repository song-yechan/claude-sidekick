import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/category_detail_screen.dart';
import '../screens/book/book_detail_screen.dart';
import '../screens/note/note_detail_screen.dart';
import '../widgets/layout/main_layout.dart';

/// 라우터 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPage = state.matchedLocation == '/auth';

      // 로딩 중이면 리다이렉트 안함
      if (authState.isLoading) return null;

      // 인증 안됐으면 로그인 페이지로
      if (!isAuthenticated && !isAuthPage) {
        return '/auth';
      }

      // 인증됐는데 로그인 페이지면 홈으로
      if (isAuthenticated && isAuthPage) {
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
    ],
  );
});
