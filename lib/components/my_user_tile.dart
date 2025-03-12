/*
User List Tile

This is to display each user as a nice tile.We will use this when we need to display a list of users, for e.g. in the user search results or viewing the followers/following list.
 */

import 'package:flutter/material.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;

  const MyUserTile({super.key, required this.user});

  //Build UI
  @override
  Widget build(BuildContext context) {
    //Container
    return Container(
      //padding outside
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),

      //padding inside
      padding: EdgeInsets.all(5),

      decoration: BoxDecoration(
        //color of tile
        color: Theme.of(context).colorScheme.secondary,

        //Curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      child: ListTile(
        //name of the user
        title: Text(user.name),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),

        //username of the user
        subtitle: Text('@${user.username}'),
        subtitleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),

        //profile icon
        leading: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),

        //on tap -> go to user profile
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(uid: user.uid),
              ),
            ),

        //arrow forward icon
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
