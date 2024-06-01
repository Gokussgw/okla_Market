import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is imported

class ProductPage extends StatelessWidget {
  final QueryDocumentSnapshot product;
  final User user;  // Ensure you have the User object

  const ProductPage({super.key, required this.product, required this.user});

  Future<void> addToCart() async {
  DocumentReference cartRef = FirebaseFirestore.instance
      .collection('cart') // Note: Changed from 'carts' to 'cart'
      .doc(user.uid)
      .collection('items')
      .doc(product.id);

  await cartRef.set({
    'name': product['name'],
    'price': product['price'],
    'imageUrl': product['imageUrl'],
    'quantity': 1, // Default quantity is 1
  }).then((value) => print("Product Added to Cart"))
    .catchError((error) => print("Failed to add product to cart: $error"));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(product['imageUrl'], fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product['name'], style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Text('\$${product['price']}', style: const TextStyle(color: Colors.grey, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product['details'], style: const TextStyle(color: Colors.black, fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
