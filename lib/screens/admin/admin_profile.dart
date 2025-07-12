import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle settings tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
                // Handle logout tap
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}