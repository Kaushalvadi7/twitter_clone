import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Please enter your email address."),
        ),
      );
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Password reset link sent! Check your email."),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(e.message ?? "Failed to send reset email."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            const Text(
              "Enter your email and we'll send you a password reset link",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email Address",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: passwordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}


