import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    checkboxTheme: CheckboxThemeData(checkColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      return Colors.black;
    })),
    primaryColor: Colors.black,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Colors.white,
        onSecondary: Colors.black,
        secondary: Colors.black));
