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

  /*
  LIKES
   */
  //user tapped like(or unlike)
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  //show option for post
  void _showOptions() {
    //check if this post is owned bty hte user or not
    String currentUid = AuthService().getCurrentUserid();
    final bool isOwnPost = widget.post.uid == currentUid;

    //show options for post
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
                    _reportPostConfirmationBox();
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
                    _blockUserConfirmationBox();
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

  //report post confirmation
  void _reportPostConfirmationBox() {
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
                  "Report Message",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to report this message?",
              style: TextStyle(fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              //report button
              TextButton(
                onPressed: () async {
                  //close box
                  Navigator.pop(context);

                  //report user
                  await databaseProvider.reportUser(
                    widget.post.id,
                    widget.post.uid,
                  );

                  //let user know it was sucessfully reported
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(
                      content: Text("Message reported Successfully!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text("Report"),
              ),
            ],
          ),
    );
  }

  //Block user confirmation
  void _blockUserConfirmationBox() {
    BuildContext rootContext =
        context; // Save root context before opening dialog

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Block User?"),
            content: const Text("Are you sure you want to block this user?"),
            actions: [
              //cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              //block button
              TextButton(
                onPressed: () async {
                  //close box
                  Navigator.pop(context);

                  //report user
                  await databaseProvider.blockUser(widget.post.uid);

                  //let user know use was sucessfully block
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(content: Text("User Blocked!")),
                  );
                },
                child: const Text("Block"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //does the current user like this post?
    bool likedByCurrentUser = listeningProvider.isPostLikedByCurrentUser(
      widget.post.id,
    );

    //listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

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

            const SizedBox(height: 20),

            //message
            Text(
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            const SizedBox(height: 20),

            //buttons -> like + comment
            Row(
              children: [
                //like button
                GestureDetector(
                  onTap: _toggleLikePost,
                  child:
                      likedByCurrentUser
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(
                            Icons.favorite_border,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                ),

                const SizedBox(width: 5),

                //like count
                Text(
                  likeCount != 0 ? likeCount.toString() : '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
