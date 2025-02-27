import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  //provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //show option for post
  void _showOptions() {
    //check if this post is owned bty hte user or not
    String currentUid = AuthService().getCurrentUserid();
    final bool isOwnPost = widget.post.uid == currentUid;

    //show options
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              //this post belong to current user
              if (isOwnPost) ...[
                //delete message butoon
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    //pop option box
                    Navigator.pop(context);

                    //handle delete action
                    await databaseProvider.deletePost(widget.post.id);
                  },
                ),
              ]
              //this post does not belong to current user
              else ...[
                //report post button
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
,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //container
    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        //padding outside
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

        //padding inside
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          //color of post tile
          color: Theme.of(context).colorScheme.secondary,

          //Curve corners
          borderRadius: BorderRadius.circular(8),
        ),

        //Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top section: profile pic /name/ username
            GestureDetector(
              onTap: widget.onUserTap,

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
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 5),

                  //username handle
                  Text(
                    '@${widget.post.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  //message
                  Text(
                    widget.post.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  const Spacer(),

                  //button -> more option :delete
                  GestureDetector(
                    onTap: () => _showOptions(),
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
