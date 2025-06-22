import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProducts extends StatefulWidget {

  const  AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final TextEditingController sellerIdController = TextEditingController();

  final TextEditingController productNameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController imageUrlController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController stockController = TextEditingController();

  Future<void> addProduct({
    required String sellerId,
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    required int stock,
  }) async {
    final doc = FirebaseFirestore.instance.collection('products').doc();
    await doc.set({
      'id': doc.id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'stock': stock,
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9EAEA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.pinkAccent),
    );

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Seller Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black87,
      // ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListView(
              children: [
                const Text(
                  'Add New Product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                const Text('Seller ID'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: sellerIdController,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Seller ID'),
                ),
                const SizedBox(height: 20),

                const Text('Product Name'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: productNameController,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Product Name'),
                ),
                const SizedBox(height: 20),

                const Text('Product Description'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Product Description'),
                ),
                const SizedBox(height: 20),

                const Text('Image URL'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: imageUrlController,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Image URL'),
                ),
                const SizedBox(height: 20),

                const Text('Price'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Product Price'),
                ),
                const SizedBox(height: 20),

                const Text('Stock'),
                const SizedBox(height: 5),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration.copyWith(hintText: 'Enter Stock Quantity'),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {
                    try {
                      await addProduct(
                        sellerId: sellerIdController.text.trim(),
                        name: productNameController.text.trim(),
                        description: descriptionController.text.trim(),
                        imageUrl: imageUrlController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                        stock: int.parse(stockController.text.trim()),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product added successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add Product', style: TextStyle(fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
