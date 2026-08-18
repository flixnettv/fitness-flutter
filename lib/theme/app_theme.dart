import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.lightPrimary
          : AppColors.lightPrimary;

  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.lightSecondary
          : AppColors.lightSecondary;

  static Color third(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.lightThird
          : AppColors.lightThird;

  static Color fourth(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.lightFourth
          : AppColors.lightFourth;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkCard
          : Colors.white;

  static Color textField(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkTextField
          : AppColors.lightBgTextField;

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightThird,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      dividerColor: Colors.black.withOpacity(0.06),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightThird,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      cardColor: AppColors.darkCard,
      dividerColor: Colors.white.withOpacity(0.08),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
