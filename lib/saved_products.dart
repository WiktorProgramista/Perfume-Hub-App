import 'package:flutter/material.dart';

class SavedProducts extends StatefulWidget {
  const SavedProducts({super.key});

  @override
  State<SavedProducts> createState() => _SavedProductsState();
}

class _SavedProductsState extends State<SavedProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [],
        ),
      ),
    );
  }
}
