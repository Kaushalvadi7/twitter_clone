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

        //once registerd, create and save user profile in database
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
      //body
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                //twitter logo
                Image.asset(
                  'assets/images/twitter_logo.jpg',
                  height: 150,
                  width: 200,
                ),

                const SizedBox(height: 40),
                //create an account message
                Center(
                  child: Text(
                    "Let's create an account for you",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //name Textfield
                MyTextField(
                  controller: nameController,
                  hintText: "Enter Your Name ..",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //email Textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Enter Email Address ..",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password field
                MyTextField(
                  controller: pwController,
                  hintText: "Enter Password ..",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //confirm password field
                MyTextField(
                  controller: confirmPwController,
                  hintText: "Confirm Password ..",
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //sign up button
                MyButton(text: "Register", onTap: register),

                const SizedBox(height: 50),

                //Already a member? Login Here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 5),

                    //login here
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login Here",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
