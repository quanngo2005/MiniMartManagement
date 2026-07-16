import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryContainer,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.backgroundSlate,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 68,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBright,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: _outlineBorder(AppColors.borderGray),
        enabledBorder: _outlineBorder(AppColors.borderGray),
        focusedBorder: _outlineBorder(AppColors.primary, width: 2),
        errorBorder: _outlineBorder(AppColors.statusError),
        focusedErrorBorder: _outlineBorder(AppColors.statusError, width: 2),
        hintStyle: const TextStyle(
          color: AppColors.outlineVariant,
          fontSize: 14,
        ),
      ),
    );
  }

  static OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
