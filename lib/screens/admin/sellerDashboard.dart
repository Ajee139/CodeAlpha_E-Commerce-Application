import 'package:ecomm/screens/admin/all_orders_page.dart';
import 'package:ecomm/screens/admin/home.dart';
import 'package:ecomm/screens/admin/product_form.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Go back to Home tab
      });
      return false; // Don't exit the app
    }
    return true; // Allow exit
  }

  @override
  Widget build(BuildContext context) {
    
    final List<Widget> pages = [
      AdminHome(onAddPressed: () => _onItemTapped(1)), // ← ✅ Fix is here
      ProductFormPage(isEdit: false),
      const AllOrdersPage(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Products'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          ],
        ),
      ),
    );
  }
}
