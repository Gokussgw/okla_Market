import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://okla-market.appspot.com'); // Replace with your Firebase Storage bucket

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController(); // For displaying the date

  DateTime? selectedDate;
  Uint8List? _image;
  bool _isProcessing = false;

  Future<void> signUpWithEmailAndPassword() async {
    setState(() {
      _isProcessing = true;
    });

    if (selectedDate == null || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields and upload an image')));
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Upload the profile image to Firebase Storage
        final ref = _storage.ref().child('user_images').child('${user.uid}.jpg');
        await ref.putData(_image!);  // Upload the image
        final imageUrl = await ref.getDownloadURL();  // Retrieve the image URL

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'dateOfBirth': selectedDate!.toIso8601String(),
          'imageUrl': imageUrl,  // Store the URL of the image in Firestore
        });

        // Navigate to HomePage after successful sign up
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign up: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final pickedImageData = await pickedImage.readAsBytes();  // Read image data as bytes
      setState(() {
        _image = pickedImageData;  // Store image data as Uint8List
      });
    }
  }

  void _pickDateDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          selectedDate = pickedDate;
          dobController.text = "${pickedDate.toLocal()}".split(' ')[0];  // Set the text of the Date of Birth TextField
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _image != null ? MemoryImage(_image!) : null,
                child: _image == null ? const Icon(Icons.camera_alt, size: 40) : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
                onPressed: _pickImage,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(labelText: "Date of Birth"),
                readOnly: true, // Prevent keyboard from appearing
                onTap: _pickDateDialog,
              ),
              const SizedBox(height: 20),
              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: signUpWithEmailAndPassword,
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
