import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트 인스턴스
final supabase = Supabase.instance.client;

/// 현재 로그인한 사용자
User? get currentUser => supabase.auth.currentUser;

/// 현재 세션
Session? get currentSession => supabase.auth.currentSession;
