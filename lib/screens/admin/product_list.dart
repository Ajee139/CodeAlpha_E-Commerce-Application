import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/models/product_sort_option.dart';
import 'package:ecomm/providers/product_stats_provider.dart';
import 'package:ecomm/screens/admin/product_form.dart';
import 'package:ecomm/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  final ProductSortOption sortOption;

  const ProductList({super.key, required this.sortOption});

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

            // Filter
            final filtered = docs.where((doc) {
              final name = doc['name'].toString().toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            // Sort
            filtered.sort((a, b) {
              switch (widget.sortOption) {
                case ProductSortOption.dateNewest:
                  return _getCreatedAt(b).compareTo(_getCreatedAt(a));
                case ProductSortOption.dateOldest:
                  return _getCreatedAt(a).compareTo(_getCreatedAt(b));
                case ProductSortOption.priceHighToLow:
                  return (b['price'] ?? 0).compareTo(a['price'] ?? 0);
                case ProductSortOption.priceLowToHigh:
                  return (a['price'] ?? 0).compareTo(b['price'] ?? 0);
              }
            });

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
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SizedBox(
                            width: 500,
                            child: ProductFormPage(
                              isEdit: true,
                              productId: doc.id,
                              productData: doc.data(),
                              isDialog: true,
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

  Timestamp _getCreatedAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data().containsKey('created_at') && doc['created_at'] != null) {
      return doc['created_at'] as Timestamp;
    }
    return Timestamp(0, 0); // fallback for missing timestamps
  }
}
