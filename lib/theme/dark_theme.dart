import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  textTheme: GoogleFonts.robotoTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      return Colors.orange;
    }),
  ),
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey[900]!,
    onSecondary: Colors.orange.shade800,
    secondaryContainer: Colors.red,
    secondary: Colors.grey[900]!,
  ),
);
