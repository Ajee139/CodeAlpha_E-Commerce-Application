import 'package:ecomm/screens/admin/addProducts.dart';
import 'package:ecomm/screens/admin/sellerDashboard.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'home_page.dart';


import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/product_stats_provider.dart'; // <-- you create this


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductStatsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      // initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/addProducts': (context) => AddProducts(),
        '/dashboard': (context) => Dashboard(),
      },
    );
  }
}
