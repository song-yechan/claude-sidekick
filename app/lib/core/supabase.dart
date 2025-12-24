/// Supabase 클라이언트 유틸리티
///
/// 앱 전역에서 사용하는 Supabase 클라이언트 인스턴스와
/// 편의를 위한 getter 함수들을 제공합니다.
///
/// Supabase 초기화는 main.dart에서 수행되며,
/// 이 파일에서는 초기화된 클라이언트에 접근합니다.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트 싱글톤 인스턴스
///
/// 데이터베이스, 인증, Edge Function 등 모든 Supabase 기능에 접근합니다.
final supabase = Supabase.instance.client;

/// 현재 로그인한 사용자 정보
///
/// 로그인되지 않은 경우 null을 반환합니다.
User? get currentUser => supabase.auth.currentUser;

/// 현재 활성화된 세션 정보
///
/// 로그인되지 않은 경우 null을 반환합니다.
/// 세션에는 액세스 토큰, 리프레시 토큰 등이 포함됩니다.
Session? get currentSession => supabase.auth.currentSession;
