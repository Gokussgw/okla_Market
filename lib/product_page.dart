import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ProductPage extends StatelessWidget {
  final QueryDocumentSnapshot product;

  ProductPage({required this.product});

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
              padding: EdgeInsets.all(16),
              child: Text(product['name'], style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Text('\$${product['price']}', style: TextStyle(color: Colors.grey, fontSize: 20)),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(product['details'], style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
