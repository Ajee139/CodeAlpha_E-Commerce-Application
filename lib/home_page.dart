import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String?> getFullName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['full_name'] ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getFullName(),
      builder: (context, snapshot) {
        final fullName = snapshot.data ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            actions: [
              
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                  ),
                  child: Text(
                    'Hello, $fullName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    // Navigate to profile page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to settings page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
             
                  title: const Text('Logout', style: TextStyle(color: Colors.red),),
                  onTap: () async{
                     await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                
              ],
            ),
          ),
          body: const Center(child: Text('This is the Home Page')),
        );
      },
    );
  }
}
