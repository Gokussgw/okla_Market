import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SellPage extends StatefulWidget {
  final User user;

  SellPage({required this.user});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;
  String? _uploadedImageUrl;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);  // Prepare file for upload
      // Immediately display the selected image before uploading
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _uploadedImageUrl = 'data:image/jpg;base64,' + base64Encode(bytes);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_imageFile == null || _nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and pick an image')));
      return;
    }
    try {
      String imageUrl = await uploadImage(_imageFile!);
      FirebaseFirestore.instance.collection('products').add({
        'userId': widget.user.uid,
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
      });
      _setUploadedImageUrl(imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading product: $e')));
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = 'products_images/${DateTime.now().millisecondsSinceEpoch}_${widget.user.uid}.jpg';
    // Specify the storage bucket explicitly if the default one doesn't work
    FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'okla-market.appspot.com');
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }


  void _setUploadedImageUrl(String url) {
    setState(() {
      _uploadedImageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sell Your Product')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Pick Image',
            ),
            _uploadedImageUrl == null
                ? Text('No image selected.')
                : Image.network(
              _uploadedImageUrl!,
              height: 300,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!.toDouble()
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Text('Failed to load image'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: Text('Upload Product'),
            ),
          ],
        ),
      ),
    );
  }
}
