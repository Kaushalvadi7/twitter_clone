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
  //access to firebase auth service
  final _auth = AuthService();

  //text controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  //login method
  void login() async {
    //show loading circle
    showLoadingCircle(context);

    //attempt login
    try {
      await _auth.signInWithEmailPassword(
        emailController.text,
        pwController.text,
      );

      //finished loading
      if (mounted) hideLoadingCircle(context);
    }
    //catch any errors...
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      //body
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 49),

                  //twitter logo
                  Image.asset(
                    'assets/images/twitter_logo.jpg',
                    height: 150,
                    width: 200,
                  ),

                  const SizedBox(height: 80),
                  //message,app slogan
                  Center(
                    child: Text(
                      "Welcome Back! Log in to continue",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 29),

                  //email Text field
                  MyTextField(
                    controller: emailController,
                    hintText: "Enter Email Address ..",
                    obscureText: false,
                  ),

                  const SizedBox(height: 21),

                  //password field
                  MyTextField(
                    controller: pwController,
                    hintText: "Enter Password ..",
                    obscureText: true,
                  ),

                  const SizedBox(height: 22),

                  //forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return ForgotPasswordPage();
                        }));
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

                  const SizedBox(height: 200),

                  //sign in button
                  MyButton(text: "Login", onTap: login),

                  const SizedBox(height: 30),

                  //Not a member? Register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.w700,fontSize: 17
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
