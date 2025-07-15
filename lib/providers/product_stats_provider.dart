import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductStatsProvider with ChangeNotifier {
  int totalProducts = 0;
  int totalStock = 0;
  int pendingOrders = 0; // 👈 New field

  Future<void> calculateStats(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    totalProducts = docs.length;
    totalStock = docs.fold<int>(0, (sum, doc) {
      final stock = doc['stock'];
      return sum + (stock is num ? stock.toInt() : 0);
    });

    // 👇 Calculate pending orders from Firestore
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Processing')
        .get();

    pendingOrders = ordersSnapshot.docs.length;

    notifyListeners();
  }
}
