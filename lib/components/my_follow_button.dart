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
      padding: const EdgeInsets.all(10.0),

      //Curve corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),

        //Material button
        child: MaterialButton(
          //padding inside
          padding: const EdgeInsets.symmetric(horizontal: 29,vertical: 14),
          onPressed: onPressed,

          //color
          color:
              isFollowing ? Colors.blue : Colors.blue,

          // add border when following
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: Theme.of(context).colorScheme.inversePrimary,width: 2)
          ),

          // remove splash color when background is transparent
          splashColor: isFollowing ? Colors.black26 : null,


          //text
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
