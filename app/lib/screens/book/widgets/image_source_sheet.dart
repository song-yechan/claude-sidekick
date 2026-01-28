/// 이미지 소스 선택 바텀시트
///
/// 카메라 또는 갤러리 중 이미지 소스를 선택하는 바텀시트입니다.
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme.dart';

/// 이미지 소스 선택 바텀시트를 표시합니다.
///
/// 선택된 [ImageSource]를 반환하거나, 취소 시 null을 반환합니다.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: context.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppShapes.extraLarge),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // 핸들 바
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 카메라 옵션
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppShapes.medium),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            title: Text(
              context.l10n.ocr_camera,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),

          // 갤러리 옵션
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppShapes.medium),
              ),
              child: Icon(
                Icons.photo_library_rounded,
                color: context.colors.onSecondaryContainer,
              ),
            ),
            title: Text(
              context.l10n.ocr_gallery,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
