import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

  final accentColor = SystemTheme.accentColor.accent;


var acrylicTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.dark,
    surface: Colors.transparent,
    surfaceTint: Colors.transparent,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.transparent,
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
