/*
Database Service

this class handles all the data from and to firebase.

--------------------------------------------------------------------------------------------------------------------

-User profile
-post message
-likes
-comments
-Accounts stuff(report / block / delete account)
-Follow / unfollow
-Search users
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';

class DatabaseService {
  //get instance of firebase db& auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
  USER PROFILE

  when a new user register, we create an account for them, but let's also store their details in the database to display on their profile page.

   */

  //save user info
  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
  }) async {
    //get current uid
    String uid = _auth.currentUser!.uid;

    //extract username from email
    String username = email.split('@')[0];
    //e.g. kaushal@gmial.com -> username: mitch

    //create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    //convert user into a map so that we can store in firbase
    final userMap = user.toMap();

    //save user info in firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  //Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      //retrive user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      //convert doc to userprofile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }

  // Update user bio
  Future<void> updateUserBioFirebase(String bio) async {
    //get current uid
    String uid = AuthService().getCurrentUserid();

    //attempt to update in firebase
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /*
  POST MESSAGE

   */

  /*
  LIKES

   */

  /*
  COMMENTS

   */

  /*
  ACCOUNTS STUFF
   */

  /*
  FOLLOW
   */

  /*
  SEARCH USER
   */
}
