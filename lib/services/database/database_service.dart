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
import 'package:twitter_clone/models/comment.dart';
import 'package:twitter_clone/models/post.dart';
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
    //e.g. kaushal@gmail.com -> username: mitch


    //create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
      profileImageUrl: '',
      birthDate: '',
      joinedDate: DateTime.now().toIso8601String().split('T')[0],
    );

    //convert user into a map so that we can store in firebase
    final userMap = user.toMap();

    //save user info in firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  //Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      //Retrive user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      //convert doc to userprofile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }

  //update user profile
  Future<void> updateUserProfileFirebase({
    required String name,
    required String username,
    String? profileImageUrl,
    String? birthDate,
  }) async {
    String uid = AuthService().getCurrentUserid();

    Map<String, dynamic> updates = {
      'name': name,
      'username': username,
    };

    if (profileImageUrl != null) {
      updates['profileImageUrl'] = profileImageUrl;
    }
    if (birthDate != null) {
      updates['birthDate'] = birthDate;
    }

    try {
      await _db.collection("Users").doc(uid).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
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

  //Delete user info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();

    //delete user doc
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);

    //delete user posts
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();

    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    //delete likes done by this user
    QuerySnapshot allPosts = await _db.collection("Posts").get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic> ?? [];

      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    //commit batch
    await batch.commit();
  }
  /*
  POST MESSAGE

   */

  //Post a message
  Future<void> postMessageInFirebase(String message, {String? imageUrl}) async {
    try {
      //get current uid
      String uid = _auth.currentUser!.uid;

      //use this uid to get the user's profile
      UserProfile? user = await getUserFromFirebase(uid);

      //create a new post
      Post newPost = Post(
        id: '', //firebase will auto generate this
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
        imageUrl: imageUrl,
      );

      //convert post object -> map
      Map<String, dynamic> newPostMap = newPost.toMap();

      //add to firebase
      await _db.collection("Posts").add(newPostMap);
    }
    //catch any errors..
    catch (e) {
      print(e);
    }
  }

  //delete a posts
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  //get all posts
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await _db
              //go to collection -> posts
              .collection("Posts")
              //chronological order
              .orderBy('timestamp', descending: true)
              //get this data
              .get();

      //return as list of posts
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching posts: $e");
      return [];
    }
  }

  //get individual post

  /*
  LIKES
   */
  //Like a post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      //get current uid
      String uid = _auth.currentUser!.uid;

      //go to doc for this post
      DocumentReference postDoc = _db.collection("Posts").doc(postId);

      //execute like
      await _db.runTransaction((transaction) async {
        //get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        if (!postSnapshot.exists) return;

        Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        List<dynamic> likedBy = postData["likedBy"] ?? [];
        int currentLikeCount = postData["likes"] ?? 0;

        // //get list of users who like this post
        // List<String> likedBy = List<String>.from(postSnapshot['likesBy'] ?? []);

        // //get like count
        // int currentLikeCount = postSnapshot['likes'];

        //if user has not liked this post yet -> then like
        if (!likedBy.contains(uid)) {
          //add user to like list
          likedBy.add(uid);

          //increment like count
          currentLikeCount++;
        }
        //if user has already liked this post -> then unlike
        else {
          //remove user from like list
          likedBy.remove(uid);

          //decrement like count
          currentLikeCount = (currentLikeCount > 0) ? currentLikeCount - 1 : 0;
        }

        //update in firebase
        transaction.update(postDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  /*
  COMMENTS

   */

  //Add a comment to a post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      //get current user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      //create a new comment
      Comment newComment = Comment(
        id: '', //auto generated by firebase
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      //convert comment to a map
      Map<String, dynamic> newCommentMap = newComment.toMap();

      //to store in firebase
      await _db.collection("Comments").add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  //Delete a comment from a post
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection("Comments").doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

  //Fetch comments for a post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      //get comments from firebase
      QuerySnapshot snapshot =
          await _db
              .collection("Comments")
              .where("postId", isEqualTo: postId)
              .get();
      //return as al list of comments
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /*
  ACCOUNTS STUFF
   */

  //Report post
  Future<void> reportUserInFirebase(String postId, postUserId) async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //create a report map
    final report = {
      'reportedBy': currentUserId,
      'mesageId': postId,
      'messageOwnerId': postUserId,
      'timestamp': Timestamp.now(),
    };

    //update in firestore
    await _db.collection('Reports').add(report);
  }

  //Block user
  Future<void> blockUserInFirebase(String postUserId) async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //add this user to blocked list
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(postUserId)
        .set({});
  }

  //UnBlock user
  Future<void> unblockUserInFirebase(String postUserId) async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //unblock in firebase
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(postUserId)
        .delete();
  }

  //get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //get data of blocked users
    final snapshot =
        await _db
            .collection('Users')
            .doc(currentUserId)
            .collection("BlockedUsers")
            .get();

    //return as a list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /*
  FOLLOW
   */

  //Follow user
  Future<void> followUserInFirebase(String uid) async {
    //get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    //add target user to the current user's following
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .set({});

    //add current user to the target user's followers
    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .set({});
  }

  //unfollow user
  Future<void> unFollowUserInFirebase(String uid) async {
    //get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    //remove target user from current user's following
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Following")
        .doc(uid)
        .delete();

    //remove Current user from current user's followers
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("Followers")
        .doc(uid)
        .delete();

    // remove current user from target user's followers
    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUserId)
        .delete();
  }

  //Get user's followers list of uids
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    //get the followers from firebase
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Followers").get();

    //return as a nice simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  //Get a user's following: list of uids
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    //get the following from firebase
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Following").get();

    //return as a nice simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /*
  SEARCH USER
   */

  //Search users by name
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    try {
      //get users from firebase
      QuerySnapshot snapshot =
          await _db
              .collection("Users")
              .where("username", isGreaterThanOrEqualTo: searchTerm)
              .where("username", isLessThanOrEqualTo: '$searchTerm\uf8ff')
              .get();

      //return as a list of user profiles
      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
