import 'package:flutter/material.dart';
import 'package:perfume_hub_app/theme_cubit.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ustawienia',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Motyw aplikacji",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                        Consumer<ThemeProvider>(
                          builder: (context, provider, child) {
                            return DropdownButton<String>(
                              value: provider.currentTheme,
                              items: const [
                                DropdownMenuItem<String>(
                                    value: "light", child: Text("Jasny")),
                                DropdownMenuItem<String>(
                                    value: "dark", child: Text("Ciemny")),
                                DropdownMenuItem<String>(
                                    value: "system", child: Text("Systemowy")),
                              ],
                              onChanged: (String? value) {
                                provider.changeTheme(value ?? "system");
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
