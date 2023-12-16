import 'package:flutter/material.dart';
import 'package:perfume_hub_app/home_screen.dart';
import 'package:perfume_hub_app/product_details.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  List<Widget> pages = [
    const HomeScreen(),
    const ProductDetails(),
    const HomeScreen(),
    const HomeScreen()
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              backgroundColor: Colors.white,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              currentIndex: currentIndex,
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
              ],
            ),
          ),
        ));
  }
}
