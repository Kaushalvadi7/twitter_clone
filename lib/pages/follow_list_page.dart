/*
Follow list page
This page displays a tab bar for (a given uid):

- a list of  all followers
- a list of  all following
==================================================================================================
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_user_tile.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({super.key, required this.uid});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
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
    //load follower list
    loadFollowerList();

    //load following list
    loadFollowingList();
  }

  //load followers
  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
  }

  //load following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    //listen to the user followers and following
    final followers = listeningProvider.getListOfFollowersProfiles(widget.uid);
    final following = listeningProvider.getListOfFollowingProfiles(widget.uid);

    //Tab controller
    return DefaultTabController(
      length: 2,

      //Scaffold
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        //App bar
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,

          //tab
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              //Followers
              Tab(text: 'Followers'),

              //Following
              Tab(text: 'Following'),
            ],
          ),
        ),

        //Body
        body: TabBarView(
          children: [
            _buildUserList(followers, "No followers .."),
            _buildUserList(following, "Not following anyone"),
          ],
        ),
      ),
    );
  }

  // build user list , given a list of profiles
  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ?
        //empty message if there are no users
        Center(child: Text(emptyMessage))
        : ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            //get each user
            final user = userList[index];

            //return as a user list tile
            return MyUserTile(user: user);
          },
        );
  }
}
