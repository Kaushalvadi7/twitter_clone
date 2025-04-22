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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 27,),
        //posts
        GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  postCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(width: 15,),

        //followers
        GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  followersCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Followers',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 15,),

        //following
        GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  followingCount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
