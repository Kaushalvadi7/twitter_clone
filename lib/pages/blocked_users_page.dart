/*
Blocked users page

This page diaplay a list of user that have been blocked.

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //on startup
  @override
  void initState() {
    super.initState();

    //load blocked users
    loadBlockedUsers();
  }

  //load blocked users
  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockedUsers();
  }

  //show confirm unblock box
  void _showUnblockedConfirmationBox(String userid) {
    BuildContext rootContext =
        context; // Save root context before opening dialog

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
                  "Unblock User",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to unblock this user?",
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              //unblock button
              TextButton(
                onPressed: () async {
                  //unblock user
                  await databaseProvider.unblockUser(userid);

                  //close box
                  Navigator.pop(context);

                  //let user know it was sucessfully reported
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(
                      content: Text(" User Unblocked Successfully!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text("Unblock"),
              ),
            ],
          ),
    );
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    //listen to blocked users
    final blockedUsers = listeningProvider.blockedUsers;

    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //App Bar
      appBar: AppBar(
        title: Text("Blocked Users"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body:
          blockedUsers.isEmpty
              ? const Center(child: Text("No Blocked Users.."))
              : ListView.builder(
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  //get each user
                  final user = blockedUsers[index];

                  //return as a ListTile Ui
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('@${user.username}'),
                    trailing: IconButton(
                      onPressed: () => _showUnblockedConfirmationBox(user.uid),
                      icon: const Icon(Icons.block_flipped),
                    ),
                  );
                },
              ),
    );
  }
}
