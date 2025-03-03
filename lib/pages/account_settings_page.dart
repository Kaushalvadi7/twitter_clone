/*
Accounts settings page

this page contains various settings for the user account.
-delete account
 */

import 'package:flutter/material.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  //ask user to confirm account deletion
  void confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.report, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Delete Account?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to delete this account?",
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              //Delete button
              TextButton(
                onPressed: () async {
                  //close box
                  Navigator.pop(context);

                  //delete account user
                  await AuthService().deleteAccount();
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //app bar
      appBar: AppBar(
        title: const Text("Account Settings"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: Column(
        children: [
          //delete account tile
          GestureDetector(
            onTap: () => confirmDeletion(context),
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
