// import 'package:cloud_firestore/cloud_firestore.dart';

// // Function to backfill 'created_at' field in 'products' collection
// Future<void> backfillCreatedAt() async {
//   final productsRef = FirebaseFirestore.instance.collection('products');
//   final snapshot = await productsRef.get();

//   for (final doc in snapshot.docs) {
//     final data = doc.data();
//     if (!data.containsKey('created_at')) {
//       await doc.reference.update({
//         'created_at': FieldValue.serverTimestamp(),
//       });
//       print("Updated: ${doc.id}");
//     }
//   }

//   print("Backfill complete.");
// }

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addMissingCreatedAtToProducts() async {
  final productsRef = FirebaseFirestore.instance.collection('products');
  final querySnapshot = await productsRef.get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    if (data['created_at'] == null) {
      await productsRef.doc(doc.id).update({
        'created_at': FieldValue.serverTimestamp(),
      });
      print("✅ Updated: ${doc.id}");
    } else {
      print("⏭ Skipped (already has created_at): ${doc.id}");
    }
  }

  print("✅ Done updating products.");
}
