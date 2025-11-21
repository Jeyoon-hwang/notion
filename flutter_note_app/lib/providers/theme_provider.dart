import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gongstagram-inspired minimal theme provider
/// Supports Muji-style minimal themes for high school students
class ThemeProvider extends ChangeNotifier {
  StudyThemeMode _themeMode = StudyThemeMode.muji;
  String? _customFontFamily;

  StudyThemeMode get themeMode => _themeMode;
  String? get customFontFamily => _customFontFamily;

  ThemeData get currentTheme {
    switch (_themeMode) {
      case StudyThemeMode.ivory:
        return _buildIvoryTheme();
      case StudyThemeMode.pastel:
        return _buildPastelTheme();
      case StudyThemeMode.muji:
        return _buildMujiTheme();
      case StudyThemeMode.dark:
        return _buildDarkTheme();
    }
  }

  /// Change theme
  void setTheme(StudyThemeMode mode) {
    _themeMode = mode;
    _updateSystemUI();
    notifyListeners();
  }

  /// Set custom font
  void setCustomFont(String? fontFamily) {
    _customFontFamily = fontFamily;
    notifyListeners();
  }

  /// Update system UI based on theme
  void _updateSystemUI() {
    final isLight = _themeMode != StudyThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: currentTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            isLight ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // ============================================================================
  // MUJI WHITE THEME - Clean, minimal, pure white
  // ============================================================================
  ThemeData _buildMujiTheme() {
    const primaryColor = Color(0xFF2C2C2C); // Almost black
    const backgroundColor = Color(0xFFFAFAFA); // Pure white-grey
    const surfaceColor = Color(0xFFFFFFFF); // Pure white
    const textColor = Color(0xFF1A1A1A); // Dark grey

    return ThemeData(
      useMaterial3: true,
      fontFamily: _customFontFamily ?? 'SF Pro',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFF5E5E5E),
        surface: surfaceColor,
        background: backgroundColor,
        error: const Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      ),

      // Minimal card style
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
        ),
        color: surfaceColor,
      ),

      // Clean app bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),

      // Minimal buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Text styles
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================================
  // IVORY PAPER THEME - Warm, paper-like, nostalgic
  // ============================================================================
  ThemeData _buildIvoryTheme() {
    const primaryColor = Color(0xFF6B4423); // Warm brown
    const backgroundColor = Color(0xFFF5F1E8); // Ivory/cream
    const surfaceColor = Color(0xFFFFFCF5); // Light cream
    const textColor = Color(0xFF3D3026); // Dark brown

    return ThemeData(
      useMaterial3: true,
      fontFamily: _customFontFamily ?? 'SF Pro',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFF8B6F47),
        surface: surfaceColor,
        background: backgroundColor,
        error: const Color(0xFFC44536),
        onPrimary: const Color(0xFFFFFCF5),
        onSecondary: Colors.white,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      ),

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: const Color(0xFFE8DCC8), width: 1),
        ),
        color: surfaceColor,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================================
  // PASTEL THEME - Soft, calming, Instagram-worthy
  // ============================================================================
  ThemeData _buildPastelTheme() {
    const primaryColor = Color(0xFFAB87C8); // Soft purple
    const backgroundColor = Color(0xFFF8F5FF); // Light lavender
    const surfaceColor = Color(0xFFFFFAFD); // Almost white with hint of pink
    const textColor = Color(0xFF4A4458); // Dark purple-grey

    return ThemeData(
      useMaterial3: true,
      fontFamily: _customFontFamily ?? 'SF Pro',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFFFFB5D8), // Soft pink
        surface: surfaceColor,
        background: backgroundColor,
        error: const Color(0xFFFF8BA7),
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      ),

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Slightly rounder
          side: BorderSide(color: const Color(0xFFE8DDFF), width: 1),
        ),
        color: surfaceColor,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================================================
  // DARK THEME - For night studying
  // ============================================================================
  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF7C9FFF); // Soft blue
    const backgroundColor = Color(0xFF121212); // True black
    const surfaceColor = Color(0xFF1E1E1E); // Dark grey
    const textColor = Color(0xFFE8E8E8); // Light grey

    return ThemeData(
      useMaterial3: true,
      fontFamily: _customFontFamily ?? 'SF Pro',
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: const Color(0xFFB4B8FF),
        surface: surfaceColor,
        background: backgroundColor,
        error: const Color(0xFFFF6B6B),
        onPrimary: const Color(0xFF1A1A1A),
        onSecondary: const Color(0xFF1A1A1A),
        onSurface: textColor,
        onBackground: textColor,
        onError: Colors.white,
      ),

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: const Color(0xFF2C2C2C), width: 1),
        ),
        color: surfaceColor,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: _customFontFamily ?? 'SF Pro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}

/// Theme modes for "Gongstagram" aesthetics
enum StudyThemeMode {
  muji, // Muji white - clean minimal
  ivory, // Ivory paper - warm nostalgic
  pastel, // Pastel - soft Instagram-worthy
  dark, // Dark - night studying
}
