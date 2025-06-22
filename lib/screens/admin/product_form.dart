import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductFormPage extends StatefulWidget {
  final bool isEdit;
  final String? productId;
  final Map<String, dynamic>? productData;

  const ProductFormPage({
    super.key,
    this.isEdit = false,
    this.productId,
    this.productData,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final TextEditingController sellerIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.productData != null) {
      final data = widget.productData!;
      sellerIdController.text = data['seller_id'] ?? '';
      productNameController.text = data['name'] ?? '';
      descriptionController.text = data['description'] ?? '';
      imageUrlController.text = data['image_url'] ?? '';
      priceController.text = data['price'].toString();
      stockController.text = data['stock'].toString();
    }
  }

  Future<void> submit() async {
    final docRef = widget.isEdit
        ? FirebaseFirestore.instance.collection('products').doc(widget.productId)
        : FirebaseFirestore.instance.collection('products').doc();

    final payload = {
      'id': docRef.id,
      'seller_id': sellerIdController.text.trim(),
      'name': productNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'image_url': imageUrlController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'stock': int.tryParse(stockController.text.trim()) ?? 0,
    };

    await docRef.set(payload);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isEdit ? "Product updated!" : "Product added!"),
    ));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    sellerIdController.dispose();
    productNameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListView(
              children: [
                const SizedBox(height: 30),
                Text(
                  widget.isEdit ? "Edit Product" : "Add New Product",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(widget.isEdit ? "Update Product" : "Add Product", style: const TextStyle(fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
