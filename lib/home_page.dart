import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'sign_in_page.dart';
import 'sell_page.dart';
import 'product_page.dart';
import 'product_list_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
  }

  Widget _buildProductGrid() {
  return StreamBuilder<QuerySnapshot>(
    stream: _productsStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Something went wrong');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }
      var products = snapshot.data!.docs;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          return MouseRegion(
            onEnter: (_) => setState(() {}),
            onExit: (_) => setState(() {}),
            child: Card(
              elevation: 3,
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductPage(product: product)
                  ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  children: <Widget>[
                    Expanded(
                      child: Center( // Center horizontally
                        child: Image.network(product['imageUrl'], fit: BoxFit.scaleDown),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(product['name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('\$${product['price']}', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to the Market!'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Profile')),
              PopupMenuItem<int>(value: 1, child: Text('Sell Product')),
              PopupMenuItem<int>(value: 2, child: Text('Product List')),
              PopupMenuItem<int>(value: 3, child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _buildProductGrid(),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => SellPage(user: widget.user)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListPage(user: widget.user)));
        break;
      case 3:
        _confirmSignOut(context);
        break;
    }
  }

  void _confirmSignOut(BuildContext context) async {
    final bool didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }
}
