import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

  final accentColor = SystemTheme.accentColor.accent;

var transparencyTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.dark,
    surface: Colors.transparent,
    surfaceTint: Colors.transparent,
    surfaceContainer: Colors.black.withValues(alpha: 0.2),
    surfaceContainerHigh: Colors.black.withValues(alpha: 0.2),
    surfaceContainerHighest: Colors.black.withValues(alpha: 0.2),
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.transparent,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
    )
  )
);

var darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.dark,
  ),
  brightness: Brightness.dark,
);

var lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.light,
  ),
  brightness: Brightness.light,
);
