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
          totalPrice = 0;
          List<Widget> children = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            totalPrice += data['price'] * data['quantity'];

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

          children.add(
            Column(
              children: [
                ListTile(
                  title: Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: checkoutCart,
                  child: Text("Checkout", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
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
      reference.delete();
    }
  }

  void checkoutCart() async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
      .collection('cart')
      .doc(widget.user.uid)
      .collection('items')
      .get();

    List<Map<String, dynamic>> items = [];

    for (var doc in cartSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      items.add({
        'productId': doc.id,
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
        'imageUrl': data['imageUrl'],
      });
    }

    if (items.isNotEmpty) {
      DocumentReference salesRef = FirebaseFirestore.instance.collection('sales').doc();

      await salesRef.set({
        'userId': widget.user.uid,
        'items': items,
        'timestamp': FieldValue.serverTimestamp(),
        'totalPrice': totalPrice,
      });

      // Delete all items in the cart after saving them to sales
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thank you for purchasing!"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        totalPrice = 0; // Reset total price after purchase
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No items in the cart to checkout!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
