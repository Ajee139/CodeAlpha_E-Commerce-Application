import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/providers/product_stats_provider.dart';
import 'package:ecomm/screens/admin/product_form.dart';
import 'package:ecomm/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("All Products", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No products found."));
            }

            final docs = snapshot.data!.docs;

            // Update stats provider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ProductStatsProvider>().calculateStats(docs);
            });

            final filtered = docs.where((doc) {
              final name = doc['name'].toString().toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
  final doc = filtered[index];

  return ProductCard(
    data: doc.data(),
    onEdit: () {
  showDialog(
    context: context,
    barrierDismissible: false, // User must tap cancel icon to dismiss
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SizedBox(
          width: 500, // optional, for web/tablet responsiveness
          child: ProductFormPage(
            isEdit: true,
            productId: doc.id,
            productData: doc.data(),
            isDialog: true, // Add this param to change UI
          ),
        ),
      );
    },
  );
},

  );
},
  );
          },
        ),
      ],
    );
  }
}





