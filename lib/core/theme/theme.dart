import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BcTheme {
  static ThemeData get gallery {
    final base = ThemeData.light();
    final display = GoogleFonts.cormorantGaramondTextTheme(base.textTheme);
    final body = GoogleFonts.outfitTextTheme(base.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BcColors.paper,
      canvasColor: BcColors.paper,
      colorScheme: const ColorScheme.light(
        primary: BcColors.brass,
        onPrimary: BcColors.espresso,
        secondary: BcColors.brassHover,
        surface: BcColors.cream,
        onSurface: BcColors.espresso,
        outline: BcColors.line,
      ),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          fontSize: 88,
          fontWeight: FontWeight.w400,
          height: 0.95,
          letterSpacing: -1.2,
          color: BcColors.espresso,
        ),
        displayMedium: display.displayMedium?.copyWith(
          fontSize: 56,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: -0.6,
          color: BcColors.espresso,
        ),
        displaySmall: display.displaySmall?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          height: 1.1,
          letterSpacing: -0.3,
          color: BcColors.espresso,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: BcColors.espresso,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: BcColors.espresso,
        ),
        titleMedium: body.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: BcColors.espresso,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          fontSize: 17,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: BcColors.espresso,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: BcColors.muted,
        ),
        labelSmall: body.labelSmall?.copyWith(
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
    final display = GoogleFonts.cormorantGaramondTextTheme(ThemeData.dark().textTheme);
    final body = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
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
      textTheme: body.copyWith(
        displaySmall: display.displaySmall?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          height: 1.1,
          color: BcAdminColors.ivory,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.25,
          color: BcAdminColors.ivory,
        ),
        titleMedium: body.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.ivory,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          fontSize: 17,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.ivory,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: BcAdminColors.muted,
        ),
        labelSmall: body.labelSmall?.copyWith(
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
