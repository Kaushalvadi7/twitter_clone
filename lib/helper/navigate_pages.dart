//go to User page
import 'package:flutter/material.dart';
import 'package:twitter_clone/pages/profile_page.dart';

void goUserPage(BuildContext context, String uid) {
  //navigate to the page
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
  );
}
