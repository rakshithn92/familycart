import 'package:flutter/material.dart';

const _primary = Color(0xFF6C63FF);
const _surfaceHigh = Color(0xFF2A2A3E);
const canvasBackground = Color(0xFF1A1A2E);
const nodeBackground = Color(0xFF16213E);

final appTheme = ThemeData.dark(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: canvasBackground,
  colorScheme: const ColorScheme.dark(
    primary: _primary,
    secondary: Color(0xFF4ECDC4),
    tertiary: Color(0xFFFFD93D),
    surface: nodeBackground,
    surfaceContainerHighest: _surfaceHigh,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: canvasBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.3,
    ),
  ),
  cardTheme: CardThemeData(
    color: nodeBackground,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: nodeBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _primary, width: 2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _surfaceHigh,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: _surfaceHigh,
    contentTextStyle: const TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
