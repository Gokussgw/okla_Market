import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'forget_password_page.dart';
import 'admin_page.dart'; // Ensure you have an AdminPage defined

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInPage({super.key});

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Fetch user data to check for admin role
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
        var data = userDoc.data() as Map<String, dynamic>; // Explicit casting to Map<String, dynamic>
        bool isAdmin = data['isAdmin'] ?? false; // Safely use the map with []

        if (isAdmin) {
          // Navigate to AdminPage if the user is an admin
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminPage()));
        } else {
          // Navigate to HomePage if not an admin
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: userCredential.user!)));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign In"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width:120, height: 120), // Display your logo here
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.black, // Button background color
              ),
              onPressed: () => signInWithEmailAndPassword(context),
              child: const Text("Sign In"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
              child: const Text("No account? Sign up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
              },
              child: const Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
