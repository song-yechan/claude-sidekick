import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success;
    if (_isSignUp) {
      success = await authNotifier.signUp(email, password);
    } else {
      success = await authNotifier.signIn(email, password);
    }

    if (!success && mounted) {
      final errorMessage = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? '오류가 발생했습니다'),
          backgroundColor: TossColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: TossColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),

                  // 헤더
                  Text(
                    _isSignUp ? '회원가입' : '로그인',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: TossColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? '책 속 문장을 수집하고 기록해보세요'
                        : '다시 만나서 반가워요',
                    style: const TextStyle(
                      fontSize: 16,
                      color: TossColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 이메일 입력
                  const Text(
                    '이메일',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TossColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      color: TossColors.gray900,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'example@email.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!value.contains('@')) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 입력
                  const Text(
                    '비밀번호',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TossColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      fontSize: 16,
                      color: TossColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: '6자 이상 입력해주세요',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: TossColors.gray500,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 로그인/회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TossColors.white,
                              ),
                            )
                          : Text(
                              _isSignUp ? '회원가입' : '로그인',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 모드 전환 버튼
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? '이미 계정이 있으신가요? 로그인'
                            : '계정이 없으신가요? 회원가입',
                        style: const TextStyle(
                          fontSize: 14,
                          color: TossColors.gray600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
