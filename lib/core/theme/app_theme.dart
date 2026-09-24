import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized monochrome color system for PennyPal.
/// Minimal black, white, and grayscale palette.
class PennyPalColors {
  // Backgrounds
  static const black = Color(0xFF000000);
  static const nearBlack = Color(0xFF0A0A0A);
  static const background = Color(0xFF111111);

  // Surfaces & Cards
  static const surface = Color(0xFF181818);
  static const card = Color(0xFF222222);
  static const elevated = Color(0xFF2A2A2A);

  // Borders
  static const border = Color(0xFF333333);
  static const mutedBorder = Color(0xFF262626);

  // Whites & Grays
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF5F5F5);

  static const lightGray = Color(0xFFD4D4D4);
  static const gray = Color(0xFFA3A3A3);
  static const muted = Color(0xFF737373);
  static const darkGray = Color(0xFF525252);
}

/// Backwards compatibility alias mapping legacy [AppColors] to [PennyPalColors].
abstract final class AppColors {
  static const primary = PennyPalColors.white;
  static const primaryDark = PennyPalColors.card;
  static const teal = PennyPalColors.lightGray;
  static const gold = PennyPalColors.lightGray;
  static const surface = PennyPalColors.surface;
  static const background = PennyPalColors.black;
  static const text = PennyPalColors.white;
  static const muted = PennyPalColors.gray;
  static const error = PennyPalColors.lightGray;
}

abstract final class AppRadii {
  static const medium = BorderRadius.all(Radius.circular(14));
  static const large = BorderRadius.all(Radius.circular(20));
}

abstract final class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PennyPalColors.black,
    colorScheme: const ColorScheme.dark(
      primary: PennyPalColors.white,
      onPrimary: PennyPalColors.black,
      surface: PennyPalColors.surface,
      onSurface: PennyPalColors.white,
      error: PennyPalColors.lightGray,
      onError: PennyPalColors.black,
    ),
    canvasColor: PennyPalColors.black,
    cardColor: PennyPalColors.surface,
    dividerColor: PennyPalColors.mutedBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: PennyPalColors.black,
      foregroundColor: PennyPalColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: PennyPalColors.white),
      titleTextStyle: TextStyle(
        color: PennyPalColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: Typography.material2021().white.apply(
      bodyColor: PennyPalColors.white,
      displayColor: PennyPalColors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: PennyPalColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: PennyPalColors.gray, fontSize: 14),
      hintStyle: TextStyle(color: PennyPalColors.muted, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: PennyPalColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: PennyPalColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: PennyPalColors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: PennyPalColors.darkGray, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: PennyPalColors.lightGray, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PennyPalColors.white,
        foregroundColor: PennyPalColors.black,
        disabledBackgroundColor: PennyPalColors.darkGray,
        disabledForegroundColor: PennyPalColors.gray,
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: PennyPalColors.card,
        foregroundColor: PennyPalColors.white,
        side: const BorderSide(color: PennyPalColors.border),
        minimumSize: const Size.fromHeight(54),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PennyPalColors.white,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ), dialogTheme: const DialogThemeData(backgroundColor: PennyPalColors.surface),
  );

  static ThemeData get lightTheme => theme;
}
