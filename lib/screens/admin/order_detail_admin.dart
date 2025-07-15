import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const AdminOrderDetailsPage({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late String status;

  final List<String> statusOptions = [
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    status = widget.orderData['status'] ?? 'Processing';
  }

  Future<void> updateOrderStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': newStatus});

      setState(() {
        status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order status updated")),
      );
    } catch (e) {
      print('❌ Error updating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update order status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(widget.orderData['items'] ?? []);
    final total = widget.orderData['total'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Order View"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Status:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: status,
              isExpanded: true,
              items: statusOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != status) {
                  updateOrderStatus(value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text("Items:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text("Qty: ${item['quantity']}"),
                    trailing: Text(
                      "\$${double.parse(item['price'].toString()).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: \$${double.parse(total.toString()).toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
