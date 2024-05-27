import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA9j0hnCchx26uhiNW6PShj486uKxt4F88",
      appId: "1:831534010572:android:0a48d630e9c2bc73b83269",
      messagingSenderId: "831534010572",
      projectId: "okla-market",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Market',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),  // Used for body text in material components.
          bodyMedium: TextStyle(color: Colors.black),  // Used for emphasizing text that would otherwise be bodyText1.
        ),
      ),
      home: SignInPage(),
    );
  }
}
