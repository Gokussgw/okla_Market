import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is imported

class ProductPage extends StatelessWidget {
  final QueryDocumentSnapshot product;
  final User user;  // Ensure you have the User object

  const ProductPage({Key? key, required this.product, required this.user}) : super(key: key);

  Future<void> addToCart(BuildContext context) async {
    DocumentReference cartRef = FirebaseFirestore.instance
        .collection('cart') // Note: Changed from 'carts' to 'cart'
        .doc(user.uid)
        .collection('items')
        .doc(product.id);

    try {
      await cartRef.set({
        'name': product['name'],
        'price': product['price'],
        'imageUrl': product['imageUrl'],
        'quantity': 1, // Default quantity is 1
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product['name']} added to cart!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print("Failed to add product to cart: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add product to cart. Error: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // White color for back button
        title: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment(-0.15, 0),
              child: Image.asset(
                'assets/logo.png', // Ensure your assets directory contains this image.
                height: 30, // Adjust the size according to your AppBar's height
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(product['imageUrl'], fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product['name'], style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Text('\$${product['price']}', style: TextStyle(color: Colors.grey, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product['details'], style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () => addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Button color
              ),
              child: Text('Add to Cart', style: TextStyle(color: Colors.white,)),
            ),
          ],
        ),
      ),
    );
  }
}
