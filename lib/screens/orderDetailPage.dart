import 'package:flutter/material.dart';


class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(orderData['items']);
    final status = orderData['status'];
    final total = orderData['total'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${status.toString().toUpperCase()}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Items:", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text("Qty: ${item['quantity']}"),
                    trailing: Text("₦${item['price']}"),
                  );
                },
              ),
            ),
            const Divider(),
            Text("Total: ₦$total", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
