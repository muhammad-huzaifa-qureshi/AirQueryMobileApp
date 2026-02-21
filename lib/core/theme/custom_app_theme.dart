import 'package:air_query/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Air Query Custom Theme
class CustomAppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: .dark,

    colorScheme: ColorScheme(
      primary: AppColors.primary,
      onPrimary: AppColors.blackish,
      secondary: AppColors.blackish,
      onSecondary: AppColors.whitish,
      error: AppColors.error,
      onError: AppColors.whitish,
      surface: AppColors.blackish,
      onSurface: AppColors.whitish,
      brightness: .dark,
    ),

    // text field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const .symmetric(vertical: 12, horizontal: 4),

      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.whitish.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),

      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
      ),

      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // text theme
    textTheme: TextTheme(
      // Large hero titles (Login screens, Headers)
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),

      // Section Headers
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.whitish,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.whitish,
      ),

      // List titles / Card titles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.whitish,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.whitish.withValues(alpha: 0.7),
      ),

      // Standard Reading Text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.whitish,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.whitish,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.whitish.withValues(alpha: 0.6),
      ),

      // Buttons and Metadata
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
        color: AppColors.primary,
      ),
    ),
  );
}
