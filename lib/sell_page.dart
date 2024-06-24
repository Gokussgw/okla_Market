import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'home_page.dart';
import 'product_list_page.dart';

class SellPage extends StatefulWidget {
  final User user;
  final DocumentSnapshot? product;

  const SellPage({super.key, required this.user, this.product});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  Uint8List? _imageFile;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
      _detailsController.text = widget.product!['details'] ?? '';
      _quantityController.text = widget.product!['quantity'].toString();
      _uploadedImageUrl = widget.product!['imageUrl'];
    } else {
      _quantityController.text = '1'; // Default quantity
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = result.files.single.bytes;
        _uploadedImageUrl = 'data:image/jpg;base64,${base64Encode(_imageFile!)}';
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _detailsController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    try {
      String imageUrl = _uploadedImageUrl ?? '';
      if (_imageFile != null) {
        imageUrl = await uploadImage(_imageFile!);
      }

      final productData = {
        'userId': widget.user.uid,
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'details': _detailsController.text,
        'quantity': int.parse(_quantityController.text), // Convert quantity to int
        'imageUrl': imageUrl,
      };

      if (widget.product == null) {
        await FirebaseFirestore.instance.collection('products').add(productData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product uploaded successfully!')));
      } else {
        await FirebaseFirestore.instance.collection('products').doc(widget.product!.id).update(productData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated successfully!')));
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(user: widget.user)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading product: $e')));
    }
  }

  Future<String> uploadImage(Uint8List image) async {
    String fileName = 'products_images/${DateTime.now().millisecondsSinceEpoch}_${widget.user.uid}.jpg';
    FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'okla-market.appspot.com');
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Sell Your Product' : 'Edit Product')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Pick Image',
            ),
            _uploadedImageUrl == null
                ? const Text('No image selected.')
                : Image.memory(
                    base64Decode(_uploadedImageUrl!.split(',')[1]),
                    height: 300,
                    errorBuilder: (context, error, stackTrace) => const Text('Failed to load image'),
                  ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
            ),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Product Details'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: _uploadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Button color
              ),
              child: Text(widget.product == null ? 'Upload Product' : 'Update Product', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
