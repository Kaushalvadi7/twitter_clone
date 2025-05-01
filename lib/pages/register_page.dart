import 'package:flutter/material.dart';
import 'package:twitter_clone/components/my_button.dart';
import 'package:twitter_clone/components/my_loading_circle.dart';
import 'package:twitter_clone/components/my_text_field.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function() onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //access auth & db service
  final _auth = AuthService();
  final _db = DatabaseService();

  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  //register button tapped
  void register() async {
    // check if passwords match -> create user
    if (pwController.text == confirmPwController.text) {
      //show loading circle
      showLoadingCircle(context);

      //attempt to register new user
      try {
        //trying to register..
        await _auth.registerEmailPassword(
          emailController.text,
          pwController.text,
        );

        //finished loading
        if (mounted) hideLoadingCircle(context);

        //once registered, create and save user profile in database
        await _db.saveUserInfoInFirebase(
          name: nameController.text,
          email: emailController.text,
        );
      }
      //display any errors
      catch (e) {
        //finished loading
        if (mounted) hideLoadingCircle(context);

        //let user know of the error
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(title: Text(e.toString())),
          );
        }
      }
    }
    // if passwords don't match -> show error
    else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text("Passwords don't match!"),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      // Logo
                      Image.asset(
                        'assets/images/twitter_logo.jpg',
                        height: screenHeight * 0.18,
                        width: screenWidth * 0.5,
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // Heading
                      Text(
                        "Let's create an account for you",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Name
                      MyTextField(
                        controller: nameController,
                        hintText: "Enter Your Name ..",
                        obscureText: false,
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // Email
                      MyTextField(
                        controller: emailController,
                        hintText: "Enter Email Address ..",
                        obscureText: false,
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // Password
                      MyTextField(
                        controller: pwController,
                        hintText: "Enter Password ..",
                        obscureText: true,
                      ),

                      SizedBox(height: screenHeight * 0.015),

                      // Confirm Password
                      MyTextField(
                        controller: confirmPwController,
                        hintText: "Confirm Password ..",
                        obscureText: true,
                      ),

                      SizedBox(height: screenHeight * 0.08),

                      // Register Button
                      MyButton(text: "Register", onTap: register),

                      SizedBox(height: screenHeight * 0.035),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a member?",
                            style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              "Login Here",
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.inversePrimary,
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
