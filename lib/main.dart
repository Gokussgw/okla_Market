import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA9j0hnCchx26uhiNW6PShj486uKxt4F88",
      appId: "1:831534010572:android:0a48d630e9c2bc73b83269",
      messagingSenderId: "831534010572",
      projectId: "okla-market",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Market',
      home: SignInPage(),
    );
  }
}
