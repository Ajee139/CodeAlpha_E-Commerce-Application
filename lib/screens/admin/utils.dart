import 'package:cloud_firestore/cloud_firestore.dart';

// Function to backfill 'created_at' field in 'products' collection
Future<void> backfillCreatedAt() async {
  final productsRef = FirebaseFirestore.instance.collection('products');
  final snapshot = await productsRef.get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    if (!data.containsKey('created_at')) {
      await doc.reference.update({
        'created_at': FieldValue.serverTimestamp(),
      });
      print("Updated: ${doc.id}");
    }
  }

  print("Backfill complete.");
}
