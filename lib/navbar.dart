import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  Navbar({required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabTapped,
      backgroundColor: Colors.blue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle), label: 'Tambah Menu'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Checkout'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
      ],
    );
  }
}
