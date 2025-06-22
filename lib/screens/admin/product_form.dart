import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductFormPage extends StatefulWidget {
  final bool isEdit;
  final String? productId;
  final Map<String, dynamic>? productData;
  final bool isDialog;

  const ProductFormPage({
    super.key,
    this.isEdit = false,
    this.productId,
    this.productData,
    this.isDialog = false,
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

     if (widget.isDialog) {
    Navigator.pop(context); // Only pop if it’s a dialog or pushed route
  }
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
                const SizedBox(height: 16),
                // Header
                if (widget.isDialog)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isEdit ? "Edit Product" : "Add Product",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      widget.isEdit ? "Edit Product" : "Add New Product",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                // Form fields
                _buildLabeledField("Seller ID", sellerIdController, inputDecoration),
                _buildLabeledField("Product Name", productNameController, inputDecoration),
                _buildLabeledField("Product Description", descriptionController, inputDecoration, maxLines: 4),
                _buildLabeledField("Image URL", imageUrlController, inputDecoration),
                _buildLabeledField("Price", priceController, inputDecoration, isNumber: true),
                _buildLabeledField("Stock", stockController, inputDecoration, isNumber: true),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(widget.isEdit ? "Update Product" : "Add Product",
                      style: const TextStyle(fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      InputDecoration baseDecoration,
      {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: baseDecoration.copyWith(hintText: 'Enter $label'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
