import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; 

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = FirebaseFirestore.instance.collection('products').snapshots();
  }

 Future<void> _generateSalesReport() async {
  final pdf = pw.Document();

  try {
    final salesQuerySnapshot = await FirebaseFirestore.instance.collection('sales').get();
    List<Map<String, dynamic>> salesData = [];

    for (var doc in salesQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      salesData.add({
        'timestamp': DateFormat('yyyy-MM-dd – kk:mm').format(data['timestamp'].toDate()), // Format the date
        'userId': data['userId'],
        'totalPrice': data['totalPrice'].toString(),
        'items': data['items'].map((item) => item['name']).join(", "), // Assuming each item has a 'name'
      });
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Sales Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18))),
          pw.Table.fromTextArray(context: context, data: <List<String>>[
            <String>['Timestamp', 'User ID', 'Total Price', 'Items Purchased'],
            ...salesData.map((item) => [
                  item['timestamp'],
                  item['userId'],
                  item['totalPrice'],
                  item['items'],
                ])
          ]),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
          pw.Paragraph(text: 'Total Sales: \$${salesData.fold(0, (previousValue, element) => previousValue + double.parse(element['totalPrice']).toInt())}', style: pw.TextStyle(fontSize: 18)),
        ],
      ),
    );

    // Save the PDF file
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'sales_report.pdf');

  } catch (e) {
    print('Error generating sales report: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate report: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _generateSalesReport,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => FirebaseAuth.instance.signOut().then((value) => Navigator.pop(context)),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot product = snapshot.data!.docs[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('\$${product['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
