import 'package:flutter/material.dart';
import 'package:perfume_hub/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Motyw aplikacji",
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0), 
            Consumer<ThemeProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_forward_ios),
                    alignment: Alignment.bottomCenter,
                    underline: const SizedBox(),
                    isDense: true,
                    isExpanded: true,
                    elevation: 0,
                    value: provider.currentTheme,
                    items: const [
                      DropdownMenuItem<String>(
                        alignment: Alignment.bottomCenter,
                          value: "light", child: Text("Jasny")),
                      DropdownMenuItem<String>(
                        alignment: Alignment.bottomCenter,
                          value: "dark", child: Text("Ciemny")),
                      DropdownMenuItem<String>(
                        alignment: Alignment.bottomCenter,
                          value: "system", child: Text("Systemowy")),
                    ],
                    onChanged: (String? value) {
                      provider.changeTheme(value ?? "system");
                    },
                  ),
                );
              },
            ),
          ],
        )
      ),
    );
  }
}
