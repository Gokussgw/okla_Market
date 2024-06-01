import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  final User user;

  CartPage({required this.user});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(widget.user.uid)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          totalPrice = 0; // Reset total price
          var children = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            totalPrice += data['price'] * data['quantity']; // Calculate total price

            return Column(
              children: [
                ListTile(
                  leading: Image.network(data['imageUrl'], width: 100, fit: BoxFit.cover),
                  title: Text(data['name']),
                  subtitle: Text('\$${data['price']} x ${data['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => adjustQuantity(document.reference, data['quantity'] - 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => adjustQuantity(document.reference, data['quantity'] + 1),
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            );
          }).toList();

          // Add the total price in its own Column at the end of the list
          children.add(
            Column(
              children: [
                ListTile(
                  title: Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(),
              ],
            ),
          );

          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  void adjustQuantity(DocumentReference reference, int newQuantity) {
    if (newQuantity > 0) {
      reference.update({'quantity': newQuantity});
    } else {
      // Optionally remove the item if quantity becomes 0
      reference.delete();
    }
  }
}
