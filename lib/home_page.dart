import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'sign_in_page.dart';
import 'sell_page.dart';
import 'product_page.dart';
import 'product_list_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot> _productsStream;
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
    _widgetOptions = [
      _buildProductGrid(),
      ProfilePage(user: widget.user),
      SellPage(user: widget.user),
      ProductListPage(user: widget.user),
      CartPage(user: widget.user),
    ];
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
            return Card(
              elevation: 3,
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductPage(product: product, user: widget.user)
                  ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Image.network(product['imageUrl'], fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(product['name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    Text('\$${product['price']}', style: TextStyle(color: Colors.grey)),
                  ],
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
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // White color for back button
        title: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logo.png', // Ensure your assets directory contains this image.
                height: 30, // Adjust the size according to your AppBar's height
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Product List'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
  }
}
