import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  String? previewImageUrl;
  bool isUploading = false;

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
      previewImageUrl = data['image_url'];
    }
  }

  Future<void> submit() async {
  if (!_validateInputs()) return;

  final collection = FirebaseFirestore.instance.collection('products');

  if (widget.isEdit && widget.productId != null) {
    final docRef = collection.doc(widget.productId);

    // Fetch existing data to retain `created_at`
    final existing = await docRef.get();
    final existingCreatedAt = existing.data()?['created_at'];

    final payload = {
      'id': docRef.id,
      'seller_id': sellerIdController.text.trim(),
      'name': productNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'image_url': imageUrlController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'stock': int.tryParse(stockController.text.trim()) ?? 0,
      'created_at': existingCreatedAt ?? FieldValue.serverTimestamp(), // retain or fallback
    };

    await docRef.set(payload);
  } else {
    final docRef = collection.doc();
    final payload = {
      'id': docRef.id,
      'seller_id': sellerIdController.text.trim(),
      'name': productNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'image_url': imageUrlController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
      'stock': int.tryParse(stockController.text.trim()) ?? 0,
      'created_at': FieldValue.serverTimestamp(),
    };
    await docRef.set(payload);
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(widget.isEdit ? "Product updated!" : "Product added!"),
  ));

  if (widget.isDialog) Navigator.pop(context);
}
bool _validateInputs() {
  if (sellerIdController.text.isEmpty ||
      productNameController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      imageUrlController.text.isEmpty ||
      double.tryParse(priceController.text) == null ||
      int.tryParse(stockController.text) == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields correctly.')),
    );
    return false;
  }
  return true;
}

  Future<void> pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.single.bytes == null) return;

    final fileBytes = result.files.single.bytes!;
    final fileName = result.files.single.name;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/di04amjly/image/upload'),
    );
    request.fields['upload_preset'] = 'my_unsigned_preset';
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    setState(() => isUploading = true);
    final response = await request.send();
    setState(() => isUploading = false);

    final resBody = await response.stream.bytesToString();
    final json = jsonDecode(resBody);

    if (json['secure_url'] != null) {
      setState(() {
        imageUrlController.text = json['secure_url'];
        previewImageUrl = json['secure_url'];
      });
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
                if (widget.isDialog)
                  Row(
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
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  )
                else
                  const Text(
                    'Add New Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16),

                if (previewImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.network(previewImageUrl!, height: 150, fit: BoxFit.cover),
                  ),

                _buildField("Seller ID", sellerIdController, inputDecoration),
                _buildField("Product Name", productNameController, inputDecoration),
                _buildField("Product Description", descriptionController, inputDecoration, maxLines: 4),
                _buildImageField(inputDecoration),
                _buildField("Price", priceController, inputDecoration, isNumber: true),
                _buildField("Stock", stockController, inputDecoration, isNumber: true),

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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, InputDecoration decoration,
      {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: decoration.copyWith(hintText: "Enter $label"),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageField(InputDecoration decoration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Image URL"),
        const SizedBox(height: 5),
        TextFormField(
          controller: imageUrlController,
          onChanged: (val) => setState(() => previewImageUrl = val),
          decoration: decoration.copyWith(
            hintText: "Enter Image URL",
            suffixIcon: IconButton(
              icon: isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload, color: Colors.pinkAccent),
              onPressed: isUploading ? null : pickAndUploadImage,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
