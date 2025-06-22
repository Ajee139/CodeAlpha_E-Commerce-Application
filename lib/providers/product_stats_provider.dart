import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductStatsProvider with ChangeNotifier {
  int totalProducts = 0;
  int totalStock = 0;

  Future<void> calculateStats(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    totalProducts = docs.length;
    totalStock = docs.fold<int>(0, (sum, doc) {
      final stock = doc['stock'];
      return sum + (stock is num ? stock.toInt() : 0);
    });
    notifyListeners();
  }
}
