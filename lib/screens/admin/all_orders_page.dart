import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/screens/admin/order_detail_admin.dart';
import 'package:ecomm/screens/orderDetailPage.dart';
import 'package:flutter/material.dart';

class AllOrdersPage extends StatelessWidget {
  const AllOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Orders"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data();
              final orderId = orderDoc.id;
              final userId = order['user_id'] ?? 'Unknown';
              final status = order['status'] ?? 'Pending';
              final total = order['total'] ?? 0;
              final createdAt = order['created_at']?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text("Order #$orderId"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User ID: $userId"),
                      Text("Status: ${status.toString().toUpperCase()}"),
                      Text("Total: ₦${total.toStringAsFixed(2)}"),
                      if (createdAt != null)
                        Text("Date: ${createdAt.toLocal().toString().split(' ').first}"),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminOrderDetailsPage(
                          orderData: order,
                          orderId: orderId,
                          
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
