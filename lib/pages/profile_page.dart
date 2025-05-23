import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twitter_clone/components/my_bio_box.dart';
import 'package:twitter_clone/components/my_follow_button.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/components/my_profile_stats.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/pages/follow_list_page.dart';
import 'package:twitter_clone/pages/post_message_page.dart';
import 'package:twitter_clone/pages/search_page.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_provider.dart';
import 'edit_profile_page.dart';

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

  //isfollowing state
  bool _isFollowing = false;

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

    //load followers and following for this user
    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);

    //update following state
    _isFollowing = databaseProvider.isFollowing(widget.uid);

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

  //toggle follow -> follow / unfollow
  Future<void> togglefollow() async {
    //unfollow
    if (_isFollowing) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Unfollow"),
              content: const Text(
                "Are you sure you want to unfollow this user? Their posts will no longer appear in your home timeline, but you can still view their profile.",
              ),
              actions: [
                //cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                //yes
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    //perform unfollow
                    await databaseProvider.unfollowUser(widget.uid);
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
      );
    }
    //follow
    else {
      await databaseProvider.followUser(widget.uid);
    }

    //update isfollowing state
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }


  //show post message page
  void _openPostMessageBox() {
    showDialog(context: context, builder: (context) => PostMessagePage());
  }

  //build ui
  @override
  Widget build(BuildContext context) {
    //listen to user posts
    final userAllPosts = listeningProvider.filterUserPosts(widget.uid);

    //listen to followers and following count
    final followersCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    //listen to its following
    _isFollowing = listeningProvider.isFollowing(widget.uid);
    //scaffold
    return Scaffold(
      //app bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF1DA1F2),
        centerTitle: true,
        title: Text(
          _isLoading ? '' : user!.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black45,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => goHomePage(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
        ),

        //search button
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            icon: const Icon(Icons.search, size: 28),
          ),
          const SizedBox(width: 5),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              Share.share(
                'Check out this awesome profile on twitter_clone: https://twitter_clone.com/user/123',
                subject: 'Profile Share',
              );
            },
            icon: const Icon(Icons.share, size: 28),
          ),


          const SizedBox(width: 10),
        ],
      ),

      //body
      body: ListView(
        children: [
          //profile picture
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Border color
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        user != null &&
                                user!.profileImageUrl != null &&
                                user!.profileImageUrl!.isNotEmpty
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                    child:
                        user == null ||
                                user!.profileImageUrl == null ||
                                user!.profileImageUrl!.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                ),
                // Edit Button
                if (user != null && user!.uid == currentUserId)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 0, // Removes shadow for cleaner look
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: Colors.grey, // Border color
                          width: 1.5, // Border thickness
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user!),
                        ),
                      );
                      // Refresh user data after coming back from EditProfilePage
                      await loadUser();
                      setState(() {}); // Optional: force rebuild if needed
                    },
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                //follow /unfollow button
                //only show if the user is viewing someone else's profile
                if (user != null && user!.uid != currentUserId)
                  MyFollowButton(onPressed: togglefollow, isFollowing: _isFollowing),
              ],
            ),
          ),

          // name and verification
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 25),
                  Text(
                    _isLoading ? '' : user!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/verified.png', // Use your verified badge icon path
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 5),
                  if (user != null && user!.uid == currentUserId)
                  Text(
                    "Get Verified",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 25),
                  //username handle
                  Text(
                    _isLoading ? '' : '@${user!.username}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),


          const SizedBox(height: 18,),
          Row(
            children: [
              const SizedBox(width: 25,),
              Icon(Icons.cake_outlined, size: 17, color: Colors.grey),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Born ${user?.birthDate?.isNotEmpty == true ? formatDate(user!.birthDate!) : 'N/A'}',
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.calendar_month_rounded, size: 17, color: Colors.grey),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Joined ${user?.joinedDate?.isNotEmpty == true ? formatDate(user!.joinedDate!) : 'N/A'}',
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          //profile stats -> number of posts / follower /following
          MyProfileStats(
            postCount: userAllPosts.length.toString(),
            followersCount: followersCount, //user!.followers.length,
            followingCount: followingCount, //user!.following.length,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowListPage(uid: widget.uid),
                  ),
                ),
          ),

          const SizedBox(height: 25),
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

                //button to edit bio
                //only show if this is the current user
                if (user != null && user!.uid == currentUserId)
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
                  return MyPostTile(
                    post: post,
                    onUserTap: () {},
                    onPostTap: () => goPostPage(context, post),
                  );
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DA1F2),
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}

//date format
String formatDate(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('MMMM d, y').format(date); // e.g. April 22, 2025
  } catch (e) {
    return 'N/A';
  }
}
