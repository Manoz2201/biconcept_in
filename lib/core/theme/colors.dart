import 'package:flutter/material.dart';

/// Public cream-gallery tokens. Photography carries luxury; the canvas stays warm and readable.
abstract final class BcColors {
  static const paper = Color(0xFFF6F1E8);
  static const stone = Color(0xFFEDE6D9);
  static const cream = Color(0xFFFFFBF5);
  static const espresso = Color(0xFF2C241C);
  static const muted = Color(0xFF6F675C);
  static const line = Color(0xFFD9D0C3);
  static const brass = Color(0xFFB08A5A);
  static const brassHover = Color(0xFFC4A06E);
  static const photoInk = Color(0xFFF7F1E6);
  static const danger = Color(0xFFC47A74);
  static const radius = 8.0;

  /// Aliases used across public widgets (mapped onto the cream gallery).
  static const ink = paper;
  static const charcoal = stone;
  static const panel = cream;
  static const gold = brass;
  static const goldSoft = brassHover;
  static const ivory = espresso;
}

/// Espresso console — kept dark so staff know they are in the back office.
abstract final class BcAdminColors {
  static const ink = Color(0xFF0A0A0A);
  static const charcoal = Color(0xFF141414);
  static const panel = Color(0xFF1A1A1A);
  static const line = Color(0xFF2C2C2C);
  static const gold = Color(0xFFC4A574);
  static const goldSoft = Color(0xFFD4C4A8);
  static const ivory = Color(0xFFF4F0E8);
  static const muted = Color(0xFF8A857C);
  static const danger = Color(0xFFC47A74);
}
