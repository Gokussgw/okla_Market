import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  String userEmail = "Loading...";
  String userImageUrl = "";  // State variable for user image URL

  bool _isEditingName = false;
  bool _isEditingDOB = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? "No name available";
          userEmail = data['email'] ?? "No email available";
          _dobController.text = data['dateOfBirth'] ?? "No date of birth available";
          userImageUrl = data['imageUrl'] ?? '';  // Fetching image URL from Firestore
        });
      }
    } catch (e) {
      print("Failed to fetch user details: $e");
    }
  }

  void updateNameInDatabase() {
    FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
      'name': _nameController.text,
    }).then((_) {
      print("Name updated successfully!");
      setState(() {
        _isEditingName = false; // Exit edit mode
      });
    }).catchError((error) {
      print("Failed to update name: $error");
    });
  }

  void updateDOBInDatabase() {
    FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
      'dateOfBirth': _dobController.text,
    }).then((_) {
      print("DOB updated successfully!");
      setState(() {
        _isEditingDOB = false; // Exit edit mode
      });
    }).catchError((error) {
      print("Failed to update DOB: $error");
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  userImageUrl.isNotEmpty
                      ? CircleAvatar(
                        radius: 60,
                        backgroundImage: CachedNetworkImageProvider(userImageUrl),
                        backgroundColor: Colors.transparent,
                      )
                      : CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.account_circle, size: 60),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Name'),
                  subtitle: _isEditingName
                      ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Edit name",
                          ),
                          onSubmitted: (value) => updateNameInDatabase(),
                        )
                      : Text(_nameController.text),
                  trailing: IconButton(
                    icon: Icon(_isEditingName ? Icons.save : Icons.edit),
                    onPressed: () {
                      if (_isEditingName) {
                        updateNameInDatabase();
                      } else {
                        setState(() { _isEditingName = true; });
                      }
                    },
                  ),
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(userEmail),
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  title: const Text('Date of Birth'),
                  subtitle: _isEditingDOB
                      ? TextField(
                          controller: _dobController,
                          decoration: const InputDecoration(
                            hintText: "Edit date of birth",
                          ),
                          onSubmitted: (value) => updateDOBInDatabase(),
                        )
                      : Text(_dobController.text),
                  trailing: IconButton(
                    icon: Icon(_isEditingDOB ? Icons.save : Icons.edit),
                    onPressed: () {
                      if (_isEditingDOB) {
                        updateDOBInDatabase();
                      } else {
                        setState(() { _isEditingDOB = true; });
                      }
                    },
                  ),
                ),
                const Divider(color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
