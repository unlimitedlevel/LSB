import 'package:flutter/material.dart';

class AppTheme {
  // Primary color palette - Modern blue gradient
  static const Color primaryColor = Color(0xFF2D6BEF);
  static const Color primaryLight = Color(0xFF5189FF);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Accent colors
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9191);
  static const Color accentDark = Color(0xFFD12C2C);

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF8F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFEEF2FB);
  static const Color backgroundLight = Color(0xFFF5F7FA);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Divider and border colors
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color borderColor = Color(0xFFCBD5E1);

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Elevation
  static const double cardElevation = 2.0;
  static const double buttonElevation = 3.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Typography - Font Sizes
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 17.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 30.0;
  static const double fontSize4xl = 36.0;

  // Typography - Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // Typography - Line Heights
  static const double lineHeightTight = 1.1;
  static const double lineHeightSnug = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Typography - Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  // Typography - Text Styles
  static TextStyle get headingXl => TextStyle(
    fontSize: fontSize3xl,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get headingLg => TextStyle(
    fontSize: fontSize2xl,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get headingMd => TextStyle(
    fontSize: fontSizeXl,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
    height: lineHeightSnug,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get headingSm => TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
    height: lineHeightSnug,
  );

  static TextStyle get bodyLg => TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    height: lineHeightNormal,
  );

  static TextStyle get bodyMd => TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    height: lineHeightNormal,
  );

  static TextStyle get bodySm => TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightRegular,
    color: textSecondary,
    height: lineHeightNormal,
  );

  static TextStyle get bodyXs => TextStyle(
    fontSize: fontSizeXs,
    fontWeight: fontWeightRegular,
    color: textLight,
    height: lineHeightNormal,
  );

  static TextStyle get labelLg => TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightMedium,
    color: textSecondary,
    height: lineHeightSnug,
  );

  static TextStyle get labelMd => TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    color: textSecondary,
    height: lineHeightSnug,
  );

  static TextStyle get buttonLg => TextStyle(
    fontSize: fontSizeLg,
    fontWeight: fontWeightSemiBold,
    color: Colors.white,
    height: lineHeightSnug,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonMd => TextStyle(
    fontSize: fontSizeMd,
    fontWeight: fontWeightSemiBold,
    color: Colors.white,
    height: lineHeightSnug,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonSm => TextStyle(
    fontSize: fontSizeSm,
    fontWeight: fontWeightSemiBold,
    color: Colors.white,
    height: lineHeightSnug,
    letterSpacing: letterSpacingWide,
  );

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: error,
        background: scaffoldBackground,
        surface: cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMd.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: buttonElevation,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: buttonMd,
        ),
      ),
      cardTheme: CardTheme(
        elevation: cardElevation,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: bodySm.copyWith(color: textLight),
        labelStyle: labelMd,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: textLight.withOpacity(0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: textLight.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonSm,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: bodyMd.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        elevation: 8,
      ),
      textTheme: TextTheme(
        displayLarge: headingXl,
        displayMedium: headingLg,
        displaySmall: headingMd,
        headlineMedium: headingSm,
        titleLarge: bodyLg.copyWith(fontWeight: fontWeightMedium),
        titleMedium: bodyMd.copyWith(fontWeight: fontWeightMedium),
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: labelLg,
        labelMedium: labelMd,
        labelSmall: bodyXs,
      ),
    );
  }
}
