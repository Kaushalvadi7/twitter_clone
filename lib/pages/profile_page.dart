import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_bio_box.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  //user id
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUserid();

  //text controller for bio
  final bioTextController = TextEditingController();

  //loading
  bool _isLoading = true;

  //on startup
  @override
  void initState() {
    super.initState();

    //let's load user info
    loadUser();
  }

  Future<void> loadUser() async {
    //get the user profile info
    user = await databaseProvider.userProfile(widget.uid);

    //finished loading..
    setState(() {
      _isLoading = false;
    });
  }

  //show edit bio box
  void _showEditBioBox() {
    showDialog(
      context: context,
      builder:
          (context) => MyInputAlertBox(
            textController: bioTextController,
            hintText: "Edit Bio",
            onPressed: saveBio,
            onPressedText: "Save",
          ),
    );
  }

  //save updated bio
  Future<void> saveBio() async {
    //start loading
    setState(() {
      _isLoading = true;
    });

    //update bio
    await databaseProvider.updateBio(bioTextController.text);

    //reload user
    await loadUser();

    //done loading..
    setState(() {
      _isLoading = false;
    });

    print("saving..");
  }

  //build ui
  @override
  Widget build(BuildContext context) {
    //get user posts
    final userAllPosts = listeningProvider.filterUserPosts(widget.uid);
    //scaffold
    return Scaffold(
      //app bar
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isLoading ? '' : user!.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: ListView(
        children: [
          //username handle
          Center(
            child: Text(
              _isLoading ? '' : '@${user!.username}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          const SizedBox(height: 25),

          //profile picture
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(25),
              child: Icon(
                Icons.person_2,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 25),

          //profile stats -> number of posts / follower /following

          //follo /unfollow button

          //edit bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bio",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: _showEditBioBox,
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          //bio box
          MyBioBox(text: _isLoading ? '...' : user!.bio),

          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: Text(
              "Posts",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          //list of posts from user
          userAllPosts.isEmpty
              ?
              //user post is empty
              const Center(child: Text("No Posts Yet..."))
              :
              //user post is not empty
              ListView.builder(
                itemCount: userAllPosts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  //get individual post
                  final post = userAllPosts[index];

                  //post tile ui
                  return MyPostTile(post: post, onUserTap: () {});
                },
              ),
        ],
      ),
    );
  }
}
