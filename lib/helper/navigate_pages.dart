import 'package:flutter/material.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/pages/account_settings_page.dart';
import 'package:twitter_clone/pages/blocked_users_page.dart';
import 'package:twitter_clone/pages/post_page.dart';
import 'package:twitter_clone/pages/profile_page.dart';

//go to User page
void goUserPage(BuildContext context, String uid) {
  //navigate to the profile page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
  );
}

//go to post page
void goPostPage(BuildContext context, Post post) {
  //navigate to the post page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostPage(post: post)),
  );
}

//go to blocked user page
void goBlockedUsersPage(BuildContext context) {
  //navigaate to page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BlockedUsersPage()),
  );
}

//go to account settings page
void goAccountSettingsPage(BuildContext context) {
  //navigaate to page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AccountSettingsPage()),
  );
}
