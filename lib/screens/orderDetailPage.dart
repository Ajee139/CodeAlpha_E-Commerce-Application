import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // Safely extract and type-cast values
    final List<dynamic> rawItems = orderData['items'] ?? [];
    final List<Map<String, dynamic>> items = rawItems.map((item) => Map<String, dynamic>.from(item)).toList();

    final String status = (orderData['status'] ?? 'Unknown').toString();
    final double total = (orderData['total'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// Order Status Tag
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pinkAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),

      const Text(
        "Items",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),

      /// Items List
      Expanded(
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) {
            final item = items[index];
            final name = item['name'] ?? 'Unnamed Product';
            final quantity = item['quantity'] ?? 0;
            final price = double.tryParse(item['price'].toString()) ?? 0;

            return ListTile(
              dense: true,
              title: Text(
                name.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text("Quantity: $quantity"),
              trailing: Text(
                "${price.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),

      const Divider(height: 32),

      /// Total
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          "Tota ${total.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  ),
)

      ),
    );
  }
}
