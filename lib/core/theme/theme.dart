import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class BcFonts {
  static const display = 'Cormorant Garamond';
  static const body = 'Outfit';
}

abstract final class BcTheme {
  static ThemeData get gallery {
    const espresso = BcColors.espresso;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: BcFonts.body,
      scaffoldBackgroundColor: BcColors.paper,
      canvasColor: BcColors.paper,
      colorScheme: const ColorScheme.light(
        primary: BcColors.brass,
        onPrimary: espresso,
        secondary: BcColors.brassHover,
        surface: BcColors.cream,
        onSurface: espresso,
        outline: BcColors.line,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 88,
          fontWeight: FontWeight.w400,
          height: 0.95,
          letterSpacing: -1.2,
          color: espresso,
        ),
        displayMedium: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 56,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: -0.6,
          color: espresso,
        ),
        displaySmall: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 40,
          fontWeight: FontWeight.w400,
          height: 1.1,
          letterSpacing: -0.3,
          color: espresso,
        ),
        headlineMedium: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 28,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: espresso,
        ),
        headlineSmall: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: espresso,
        ),
        titleMedium: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: espresso,
        ),
        bodyLarge: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 17,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: espresso,
        ),
        bodyMedium: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: BcColors.muted,
        ),
        labelSmall: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.4,
          color: BcColors.brass,
        ),
      ),
      dividerColor: BcColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BcColors.cream,
        hintStyle: const TextStyle(color: BcColors.muted, fontWeight: FontWeight.w400),
        labelStyle: const TextStyle(
          color: BcColors.muted,
          fontSize: 12,
          letterSpacing: 1.4,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcColors.radius),
          borderSide: const BorderSide(color: BcColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcColors.radius),
          borderSide: const BorderSide(color: BcColors.brass),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcColors.radius),
          borderSide: const BorderSide(color: BcColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BcColors.radius),
          borderSide: const BorderSide(color: BcColors.danger),
        ),
      ),
    );
  }

  static ThemeData get admin {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: BcFonts.body,
      scaffoldBackgroundColor: BcAdminColors.ink,
      canvasColor: BcAdminColors.ink,
      colorScheme: const ColorScheme.dark(
        primary: BcAdminColors.gold,
        onPrimary: BcAdminColors.ink,
        secondary: BcAdminColors.goldSoft,
        surface: BcAdminColors.charcoal,
        onSurface: BcAdminColors.ivory,
        outline: BcAdminColors.line,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 40,
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: BcAdminColors.ivory,
        ),
        headlineSmall: TextStyle(
          fontFamily: BcFonts.display,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: BcAdminColors.ivory,
        ),
        titleMedium: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.ivory,
        ),
        bodyLarge: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 17,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.ivory,
        ),
        bodyMedium: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.muted,
        ),
        labelSmall: TextStyle(
          fontFamily: BcFonts.body,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.4,
          color: BcAdminColors.gold,
        ),
      ),
      dividerColor: BcAdminColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: BcAdminColors.charcoal,
        foregroundColor: BcAdminColors.ivory,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BcAdminColors.charcoal,
        hintStyle: const TextStyle(color: BcAdminColors.muted),
        labelStyle: const TextStyle(
          color: BcAdminColors.goldSoft,
          fontSize: 12,
          letterSpacing: 1.4,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcAdminColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcAdminColors.gold),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcAdminColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcAdminColors.danger),
        ),
      ),
    );
  }
}
