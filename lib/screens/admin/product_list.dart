import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/providers/product_stats_provider.dart';
import 'package:ecomm/screens/admin/product_form.dart';
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
  
  
int _hoveredIndex = -1;


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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductFormPage(
            isEdit: true,
            productId: doc.id,
            productData: doc.data(),
          ),
        ),
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





class ProductCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;

  const ProductCard({super.key, required this.data, required this.onEdit});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF9F9F9),
                    image: DecorationImage(
                      image: NetworkImage(widget.data['image_url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (isHovered)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.data['name'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            "#${widget.data['price']}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
