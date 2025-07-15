
import 'package:ecomm/screens/admin/admin_profile.dart';
import 'package:ecomm/screens/admin/all_orders_page.dart';
import 'package:ecomm/screens/admin/home.dart';
import 'package:ecomm/screens/admin/product_form.dart';
import 'package:ecomm/screens/orders.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

//Might have to change this if it breaks my app later
  // Callback function to handle item tap
  // This function updates the selected index and rebuilds the widget
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Move pages here so _onItemTapped is in scope
    final List<Widget> pages = [
      AdminHome(onAddPressed: () => _onItemTapped(1)),
      ProductFormPage(isEdit: false),
      const AllOrdersPage(),

      AdminProfile()
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
