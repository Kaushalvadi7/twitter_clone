/*
 Profile stats widget

 this widget displays the number of posts, followers, and following of a user
 ==================================================================================================

 */

import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final String postCount;
  final int followersCount;
  final int followingCount;
  final void Function()? onTap;

  const MyProfileStats({
    super.key,
    required this.postCount,
    required this.followersCount,
    required this.followingCount,
    required this.onTap,
  });

  //Build UI
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //posts
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Text(
                  postCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  'Posts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        //followers
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Text(
                  followersCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  'Followers',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        //following
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  'Following',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
