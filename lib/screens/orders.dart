import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/screens/orderDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in.")),
      );
    }

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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

          final docs = snapshot.data?.docs ?? [];

          // Filter out documents with missing timestamps
          final validOrders = docs.where((doc) => doc.data()['created_at'] != null).toList();

          if (validOrders.isEmpty) {
            return const Center(child: Text("You have no orders."));
          }

          return ListView.builder(
            itemCount: validOrders.length,
            itemBuilder: (context, index) {
              final order = validOrders[index].data();
              final status = order['status'];
              final total = order['total'];
              final createdAt = order['created_at']?.toDate();
              final orderId = validOrders[index].id;

              return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 2,
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailsPage(orderData: order),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Order ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #$orderId",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Order Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: \$${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14),
              ),
              if (createdAt != null)
                Text(
                  "Date: ${createdAt.toLocal().toString().split(' ').first}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    ),
  ),
);

            },
          );
        },
      ),
    );
  }
}
