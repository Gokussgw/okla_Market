import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'forget_password_page.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(user: userCredential.user!)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(title: Text("Sign In"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width:120, height: 120), // Display the logo at the top of the page
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color of the button
              ),
              onPressed: () => signInWithEmailAndPassword(context),
              child: Text("Sign In"),
            ),
            SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Text color
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage())),
              child: Text("No account? Sign up"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Text color
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
              },
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
