import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    checkboxTheme: CheckboxThemeData(checkColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      return Colors.black;
    })),
    primaryColor: Colors.black,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
        background: Colors.white,
        primary: Colors.white,
        secondary: Colors.white));
