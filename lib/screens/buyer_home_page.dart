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
  Future<String> getFullName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'User';

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['full_name'] ?? 'User';
  }

  String searchQuery = '';
  ProductSortOption _sort = ProductSortOption.dateNewest;
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot<Map<String, dynamic>>> getProductStream() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }

  Timestamp _getTimestamp(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data().containsKey('created_at') && doc['created_at'] != null) {
      return doc['created_at'] as Timestamp;
    }
    return Timestamp(0, 0); // fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text("SneakShop", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: FutureBuilder<String>(
                future: getFullName(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('');
                  return Center(
                    child: Text(
                      'Hello, ${snapshot.data}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                FirebaseAuth.instance.signOut().then((_) {
                });
                  Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
  onRefresh: () async {
    setState(() {
      // Trigger StreamBuilder to rebuild
    });
  },
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<ProductSortOption>(
              icon: const Icon(Icons.filter_list),
              initialValue: _sort,
              onSelected: (value) => setState(() => _sort = value),
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
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getProductStream(),
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

              // Sort manually in Dart
              filtered.sort((a, b) {
                switch (_sort) {
                  case ProductSortOption.dateNewest:
                    return _getTimestamp(b).compareTo(_getTimestamp(a));
                  case ProductSortOption.dateOldest:
                    return _getTimestamp(a).compareTo(_getTimestamp(b));
                  case ProductSortOption.priceHighToLow:
                    return (b['price'] ?? 0).compareTo(a['price'] ?? 0);
                  case ProductSortOption.priceLowToHigh:
                    return (a['price'] ?? 0).compareTo(b['price'] ?? 0);
                }
              });

              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // Required for pull-to-refresh
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
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
),

    );
  }
}
