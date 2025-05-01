import 'package:flutter/material.dart';
import 'package:twitter_clone/components/my_button.dart';
import 'package:twitter_clone/components/my_loading_circle.dart';
import 'package:twitter_clone/components/my_text_field.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final void Function() onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  void login() async {
    showLoadingCircle(context);

    try {
      await _auth.signInWithEmailPassword(
        emailController.text,
        pwController.text,
      );

      if (mounted) hideLoadingCircle(context);
    } catch (e) {
      if (mounted) hideLoadingCircle(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, // Responsive horizontal padding
                vertical: screenHeight * 0.03,  // Optional vertical padding
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Max width for large screens
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Twitter logo
                      Image.asset(
                        'assets/images/twitter_logo.jpg',
                        height: screenHeight * 0.2,
                        width: screenWidth * 0.5,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      // Welcome message
                      Text(
                        "Welcome Back! Log in to continue",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Email
                      MyTextField(
                        controller: emailController,
                        hintText: "Enter Email Address ..",
                        obscureText: false,
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Password
                      MyTextField(
                        controller: pwController,
                        hintText: "Enter Password ..",
                        obscureText: true,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      // Login button
                      MyButton(text: "Login", onTap: login),

                      SizedBox(height: screenHeight * 0.03),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Not a member?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              "Register now",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
