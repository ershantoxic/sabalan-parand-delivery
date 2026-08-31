import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light, surface: Colors.white);
    const OutlineInputBorder border = OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: AppColors.border));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.veryLightRed,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.text, elevation: 0, centerTitle: true, surfaceTintColor: Colors.white, titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)), side: BorderSide(color: AppColors.border))),
      inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17), border: border, enabledBorder: border, focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: AppColors.primary, width: 1.5))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48), side: const BorderSide(color: AppColors.primary), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}
