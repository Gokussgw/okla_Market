import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const ProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),  // Changes the back button color to white
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,  // Ensures the container takes the full width
              alignment: Alignment.center,  // Aligns the child to the center horizontally
              child: AspectRatio(
                aspectRatio: 2,  // Keeps the image square
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,  // Background color of the image container
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),  // Changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),  // Rounded corners
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(product['imageUrl'], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product['name'], style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Text('\$${product['price']}', style: const TextStyle(color: Colors.grey, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Text(product['details'], style: const TextStyle(color: Colors.black, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
