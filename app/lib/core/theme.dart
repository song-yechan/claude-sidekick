import 'package:flutter/material.dart';

/// 토스 스타일 색상 팔레트
class TossColors {
  // Primary
  static const Color blue = Color(0xFF3182F6);
  static const Color blueLight = Color(0xFFE8F3FF);

  // Semantic
  static const Color red = Color(0xFFF04452);
  static const Color redLight = Color(0xFFFFEBED);
  static const Color green = Color(0xFF30B566);
  static const Color greenLight = Color(0xFFE8F8EF);
  static const Color orange = Color(0xFFFF8A00);
  static const Color orangeLight = Color(0xFFFFF4E5);

  // Gray Scale
  static const Color gray950 = Color(0xFF191F28);
  static const Color gray900 = Color(0xFF212529);
  static const Color gray800 = Color(0xFF333D4B);
  static const Color gray700 = Color(0xFF4E5968);
  static const Color gray600 = Color(0xFF6B7684);
  static const Color gray500 = Color(0xFF8B95A1);
  static const Color gray400 = Color(0xFFB0B8C1);
  static const Color gray300 = Color(0xFFD1D6DB);
  static const Color gray200 = Color(0xFFE5E8EB);
  static const Color gray100 = Color(0xFFF2F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  // Background
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color bgDark = Color(0xFF17171C);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TossColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: TossColors.blue,
        onPrimary: TossColors.white,
        secondary: TossColors.gray700,
        onSecondary: TossColors.white,
        surface: TossColors.white,
        onSurface: TossColors.gray900,
        error: TossColors.red,
        onError: TossColors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: TossColors.bgLight,
        foregroundColor: TossColors.gray900,
        titleTextStyle: TextStyle(
          color: TossColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: TossColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        minLeadingWidth: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TossColors.gray100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TossColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TossColors.red, width: 1),
        ),
        hintStyle: const TextStyle(
          color: TossColors.gray500,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: TossColors.blue,
          foregroundColor: TossColors.white,
          disabledBackgroundColor: TossColors.gray300,
          disabledForegroundColor: TossColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TossColors.gray700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TossColors.gray800,
          side: const BorderSide(color: TossColors.gray300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: TossColors.gray100,
        selectedColor: TossColors.blueLight,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TossColors.gray700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: TossColors.blue,
        foregroundColor: TossColors.white,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TossColors.white,
        selectedItemColor: TossColors.gray900,
        unselectedItemColor: TossColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(
        color: TossColors.gray200,
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: TossColors.gray900,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TossColors.gray900,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TossColors.gray900,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TossColors.gray900,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TossColors.gray900,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TossColors.gray900,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TossColors.gray800,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TossColors.gray700,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: TossColors.gray600,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TossColors.gray700,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: TossColors.gray600,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: TossColors.gray500,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TossColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: TossColors.blue,
        onPrimary: TossColors.white,
        secondary: TossColors.gray400,
        onSecondary: TossColors.gray900,
        surface: Color(0xFF1E1E23),
        onSurface: TossColors.gray100,
        error: TossColors.red,
        onError: TossColors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: TossColors.bgDark,
        foregroundColor: TossColors.gray100,
        titleTextStyle: TextStyle(
          color: TossColors.gray100,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A30),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TossColors.blue, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: TossColors.gray500,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: TossColors.blue,
          foregroundColor: TossColors.white,
          disabledBackgroundColor: TossColors.gray700,
          disabledForegroundColor: TossColors.gray500,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E23),
        selectedItemColor: TossColors.gray100,
        unselectedItemColor: TossColors.gray600,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
