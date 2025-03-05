/*
 Comment Tile
 
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/comment.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

import '../services/auth/auth_service.dart';
class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
  required this.comment,
  required this.onUserTap,
  });

  //show option for comment
  void _showOptions(BuildContext context) {
    //check if this post is owned bty hte user or not
    String currentUid = AuthService().getCurrentUserid();
    final bool isOwnComment = comment.uid == currentUid;

    //show options
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              //this comment belong to current user
              if (isOwnComment) ...[
                //delete comment butoon
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    //pop option box
                    Navigator.pop(context);

                    //handle delete action
                    await Provider.of<DatabaseProvider>(context, listen: false).deleteComment(comment.id, comment.postId);
                  },
                ),
              ]
              //this Comment does not belong to current user
              else ...[
                //report comment button
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("Report"),
                  onTap: () {
                    //pop option box
                    Navigator.pop(context);

                    //handle report button
                  },
                ),

                //block user button
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text("Block User"),
                  onTap: () {
                    //pop option box
                    Navigator.pop(context);

                    //handle block button
                  },
                ),
              ],

              //cancel Button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      //padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

      //padding inside
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        //color of post tile
        color: Theme.of(context).colorScheme.tertiary,

        //Curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      //Column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Top section: profile pic /name/ username
          GestureDetector(
            onTap: onUserTap,

            //Row
            child: Row(
              children: [
                //profile pic
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 10),

                //name
                Text(
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                //username handle
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const Spacer(),

                //button -> more option :delete
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          //message
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

        ],
      ),
    );
  }
}
