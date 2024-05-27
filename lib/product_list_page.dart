import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sell_page.dart';

class ProductListPage extends StatelessWidget {
  final User user;

  const ProductListPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SellPage(user: user)));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').where('userId', isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product['name']),
                subtitle: Text('\$${product['price']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('products').doc(product.id).delete();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));
                  },
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SellPage(user: user, product: product)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
