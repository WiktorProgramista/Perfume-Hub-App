import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.dark(
      background: Colors.black,
      primary: Colors.grey[900]!,
      onSecondary: Colors.orange.shade800,
      secondaryContainer: Colors.red,
      secondary: Colors.grey[800]!),
);
