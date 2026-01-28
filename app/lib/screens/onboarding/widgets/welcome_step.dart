/// 온보딩 환영 스텝
///
/// 첫 번째 스텝으로 앱 소개와 시작 버튼을 표시합니다.
library;

import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 환영 스텝 위젯
class WelcomeStep extends StatelessWidget {
  /// 다음 단계로 이동하는 콜백
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 60,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.l10n.auth_welcomeWithEmoji,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.onboarding_minimal_cta,
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(context.l10n.common_start),
            ),
          ),
        ],
      ),
    );
  }
}
