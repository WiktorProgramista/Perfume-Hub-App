import 'package:flutter/material.dart';
import 'package:perfume_hub/bottom_navigation.dart';
import 'package:perfume_hub/providers/header_provider.dart';
import 'package:perfume_hub/providers/theme_provider.dart';
import 'package:perfume_hub/theme/dark_theme.dart';
import 'package:perfume_hub/theme/light_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ChangeNotifierProvider(create: (_) => HeaderProvider()..initialize())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: provider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const BottomNavigation(),
        );
      },
    );
  }
}
