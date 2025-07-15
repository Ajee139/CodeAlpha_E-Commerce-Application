import 'package:ecomm/consts.dart';
import 'package:ecomm/providers/cart_provider.dart';
import 'package:ecomm/screens/admin/sellerDashboard.dart';
import 'package:ecomm/screens/buyer_home_page.dart';
import 'package:ecomm/screens/cart_page.dart';
import 'package:ecomm/screens/orders.dart';
import 'package:ecomm/screens/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'providers/product_stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Before Firebase init');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('After Firebase init');

  Stripe.publishableKey = stripePublishableKey;
  print('Before Stripe settings');
  await Stripe.instance.applySettings();
  print('After Stripe settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductStatsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => Dashboard(),
        '/home': (context) => const BuyerHomePage(),
        '/cart': (context) => const CartPage(),
        '/orders': (context) => OrderPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/productDetails') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          );
        }

        // fallback
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
      },
    );
  }
}
