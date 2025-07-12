import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/models/product_sort_option.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  String searchQuery = '';
  ProductSortOption _sort = ProductSortOption.dateNewest;
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot<Map<String, dynamic>>> getSortedProductStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('products');

    switch (_sort) {
      case ProductSortOption.dateNewest:
        query = query.orderBy('created_at', descending: true);
        break;
      case ProductSortOption.dateOldest:
        query = query.orderBy('created_at', descending: false);
        break;
      case ProductSortOption.priceHighToLow:
        query = query.orderBy('price', descending: true);
        break;
      case ProductSortOption.priceLowToHigh:
        query = query.orderBy('price', descending: false);
        break;
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(onPressed: (){
              Scaffold.of(context).openDrawer();
            }, icon: Icon(Icons.person));
          }
        ),
        title: const Text("Shop", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Welcome to Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),

          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.pushNamed(context, '/orders');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF9EAEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value.trim()),
                decoration: const InputDecoration(
                  hintText: "Search products",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const Text("All Products", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                PopupMenuButton<ProductSortOption>(
                  icon: const Icon(Icons.filter_list),
                  initialValue: _sort,
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ProductSortOption.dateNewest,
                      child: Text("Newest First"),
                    ),
                    const PopupMenuItem(
                      value: ProductSortOption.dateOldest,
                      child: Text("Oldest First"),
                    ),
                    const PopupMenuItem(
                      value: ProductSortOption.priceLowToHigh,
                      child: Text("Price: Low to High"),
                    ),
                    const PopupMenuItem(
                      value: ProductSortOption.priceHighToLow,
                      child: Text("Price: High to Low"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getSortedProductStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No products available."));
                  }

                  final filtered = snapshot.data!.docs.where((doc) {
                    final name = doc['name'].toString().toLowerCase();
                    return name.contains(searchQuery.toLowerCase());
                  }).toList();

                  return GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = filtered[index].data();

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/productDetails', arguments: product);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF9F9F9),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    product['image_url'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${product['price']}",
                                      style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
