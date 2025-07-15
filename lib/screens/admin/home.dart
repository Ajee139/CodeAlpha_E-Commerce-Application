import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/models/product_sort_option.dart'; // Make sure this import is correct
import 'package:ecomm/providers/product_stats_provider.dart';
import 'package:ecomm/screens/admin/product_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  final VoidCallback onAddPressed;

  const AdminHome({super.key, required this.onAddPressed});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  
  Future<String> getFullName() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'User';

  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['full_name'] ?? 'User';
}
  ProductSortOption _selectedSort = ProductSortOption.dateNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.person),
            );
          },
        ),
        automaticallyImplyLeading: false, //hides the default back button
        centerTitle: true,
        title: const Text(
          "Products",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.onAddPressed,
          ),
          
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
  height: 200, 
  
  padding: const EdgeInsets.all(16),
  alignment: Alignment.centerLeft,
  child: FutureBuilder<String>(
    future: getFullName(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Text('');
      return Center(child: Text(textAlign: TextAlign.center, 'Hello, ${snapshot.data}', style: const TextStyle(color: Colors.pinkAccent, fontSize: 20, fontWeight: FontWeight.bold)));
    },
  ),
),
ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
              Navigator.pushNamed(context, '/login');
            },
          ),            
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
  onRefresh: () async {
    final statsProvider = Provider.of<ProductStatsProvider>(context, listen: false);

    
    final productSnapshot = await FirebaseFirestore.instance.collection('products').get();
    await statsProvider.calculateStats(productSnapshot.docs);
  },
  child: LayoutBuilder(
    builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), 
          children: [
            Consumer<ProductStatsProvider>(
              builder: (context, stats, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard("Total Products", "${stats.totalProducts}", constraints, 0.45, 0.2),
                    _buildInfoCard("Total Stock", "${stats.totalStock}", constraints, 0.45, 0.2),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<ProductStatsProvider>(
              builder: (context, stats, _) {
                return Center(
                  child: _buildInfoCard("Pending Orders", "${stats.pendingOrders}", constraints, 0.9, 0.18),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("All Products", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                PopupMenuButton<ProductSortOption>(
                  icon: const Icon(Icons.filter_list),
                  initialValue: _selectedSort,
                  onSelected: (value) {
                    setState(() => _selectedSort = value);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: ProductSortOption.dateNewest,
                      child: Text("Newest First"),
                    ),
                    PopupMenuItem(
                      value: ProductSortOption.dateOldest,
                      child: Text("Oldest First"),
                    ),
                    PopupMenuItem(
                      value: ProductSortOption.priceLowToHigh,
                      child: Text("Price: Low to High"),
                    ),
                    PopupMenuItem(
                      value: ProductSortOption.priceHighToLow,
                      child: Text("Price: High to Low"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ProductList(sortOption: _selectedSort),
          ],
        ),
      );
    },
  ),
),

    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    BoxConstraints constraints,
    double widthFactor,
    double heightFactor,
  ) {
    return Container(
      width: constraints.maxWidth * widthFactor,
      height: constraints.maxHeight * heightFactor,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
