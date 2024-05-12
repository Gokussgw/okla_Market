import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String userDOB = "Loading...";
  String userImageUrl = "";  // State variable for user image URL

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        setState(() {
          userName = data['name'] ?? "No name available";
          userEmail = data['email'] ?? "No email available";
          userDOB = data['dateOfBirth'] ?? "No date of birth available";
          userImageUrl = data['imageUrl'] ?? '';  // Fetching image URL from Firestore
        });
      } else {
        setState(() {
          userName = "No name available";
          userEmail = "No email available";
          userDOB = "No date of birth available";
          userImageUrl = '';
        });
      }
    } catch (e) {
      print("Failed to fetch user details: $e");
      setState(() {
        userName = "Failed to fetch data";
        userEmail = "Failed to fetch data";
        userDOB = "Failed to fetch data";
        userImageUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            userImageUrl.isNotEmpty
                ? CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(userImageUrl),
              backgroundColor: Colors.transparent,
            )
                : CircleAvatar(
              radius: 60,
              child: Icon(Icons.account_circle, size: 60),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 20),
            Text('Name: $userName', style: TextStyle(fontSize: 20)),
            Text('Email: $userEmail', style: TextStyle(fontSize: 20)),
            Text('Date of Birth: $userDOB', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
