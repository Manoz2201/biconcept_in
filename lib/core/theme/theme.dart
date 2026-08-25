import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BcTheme {
  static ThemeData get dark {
    final display = GoogleFonts.cormorantGaramondTextTheme(
      ThemeData.dark().textTheme,
    );
    final body = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BcColors.ink,
      canvasColor: BcColors.ink,
      colorScheme: const ColorScheme.dark(
        primary: BcColors.gold,
        onPrimary: BcColors.ink,
        secondary: BcColors.goldSoft,
        surface: BcColors.charcoal,
        onSurface: BcColors.ivory,
        outline: BcColors.line,
      ),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          fontSize: 88,
          fontWeight: FontWeight.w400,
          height: 0.95,
          letterSpacing: -1.2,
          color: BcColors.ivory,
        ),
        displayMedium: display.displayMedium?.copyWith(
          fontSize: 56,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: -0.6,
          color: BcColors.ivory,
        ),
        displaySmall: display.displaySmall?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          height: 1.1,
          letterSpacing: -0.3,
          color: BcColors.ivory,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: BcColors.ivory,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: BcColors.ivory,
        ),
        titleMedium: body.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: BcColors.ivory,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          fontSize: 17,
          height: 1.65,
          fontWeight: FontWeight.w300,
          color: BcColors.ivory,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w300,
          color: BcColors.muted,
        ),
        labelSmall: body.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.4,
          color: BcColors.gold,
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
        fillColor: BcColors.charcoal,
        hintStyle: const TextStyle(color: BcColors.muted, fontWeight: FontWeight.w300),
        labelStyle: const TextStyle(
          color: BcColors.goldSoft,
          fontSize: 12,
          letterSpacing: 1.4,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcColors.gold),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: BcColors.danger),
        ),
      ),
    );
  }
}
