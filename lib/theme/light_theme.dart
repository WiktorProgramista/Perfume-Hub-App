import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    checkboxTheme: CheckboxThemeData(checkColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      return Colors.black;
    })),
    primaryColor: Colors.white,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
        background: Colors.white,
        primary: Colors.white,
        onSecondary: Colors.black,
        secondary: Colors.black));
