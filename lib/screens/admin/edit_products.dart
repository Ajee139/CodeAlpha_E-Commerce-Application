import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductPage({super.key, required this.productId, required this.productData});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController imageUrlController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.productData['name']);
    imageUrlController = TextEditingController(text: widget.productData['image_url']);
    priceController = TextEditingController(text: widget.productData['price'].toString());
    stockController = TextEditingController(text: widget.productData['stock'].toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    imageUrlController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
      'name': nameController.text.trim(),
      'image_url': imageUrlController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'stock': int.tryParse(stockController.text.trim()) ?? 0,
    });

    Navigator.pop(context); // go back to admin home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name")),
            const SizedBox(height: 10),
            TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 10),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
            const SizedBox(height: 10),
            TextField(controller: stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,
              child: const Text("Update Product"),
            )
          ],
        ),
      ),
    );
  }
}
