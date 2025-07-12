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
      return const Center(child: Text("You must be logged in."));
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You have no orders."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();
              final status = order['status'];
              final total = order['total'];
              final createdAt = order['created_at']?.toDate();
              final orderId = orders[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text("Order #$orderId"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${status.toString().toUpperCase()}"),
                      Text("Total: ₦$total"),
                      if (createdAt != null)
                        Text("Date: ${createdAt.toString().split(' ').first}"),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsPage(orderData: order),
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

