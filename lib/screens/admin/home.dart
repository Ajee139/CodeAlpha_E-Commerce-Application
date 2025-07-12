import 'package:ecomm/models/product_sort_option.dart'; // Make sure this import is correct
import 'package:ecomm/providers/product_stats_provider.dart';
import 'package:ecomm/screens/admin/product_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHome extends StatefulWidget {
  final VoidCallback onAddPressed;

  const AdminHome({super.key, required this.onAddPressed});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  ProductSortOption _selectedSort = ProductSortOption.dateNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 hides the default back button
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
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
                Center(
                  child: _buildInfoCard("Pending Orders", "15", constraints, 0.9, 0.18),
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
                ProductList(sortOption: _selectedSort),
              ],
            ),
          );
        },
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
