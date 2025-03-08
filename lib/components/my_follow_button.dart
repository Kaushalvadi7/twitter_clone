/*
Follow button for user profile
This button will allow the user to follow or unfollow a user
=========================================================================================================================

To use this widget, you need to pass in the following parameters:
-a funtion (e.g. toggleFollow() that will be called when the button is pressed )
-isFollowing (e.g.false-> then we will show follow button, true-> then we will show unfollow button)
 */

import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });
  //Build UI
  @override
  Widget build(BuildContext context) {
    //padding outside
    return Padding(
      padding: const EdgeInsets.all(25.0),

      //Curve corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),

        //Material button
        child: MaterialButton(
          //padding inside
          padding: const EdgeInsets.all(20),
          onPressed: onPressed,

          //color
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,

          //text
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
