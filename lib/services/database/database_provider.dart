import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  /*
  SERVICES

  */

  //get db & auth service
  final _db = DatabaseService();

  /*
   USER PROFILE
   */

  //get user profile from given uid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioFirebase(bio);

  /*
  Posts
   */

  //local list of posts
  List<Post> _allPosts = [];

  //get posts
  List<Post> get allPosts => _allPosts;

  //post message
  Future<void> postMessage(String message) async {
    //post message in firebase
    await _db.postMessageInFirebase(message);

    //reload data from firebase
    await loadAllPosts();
  }

  //fetch all posts
  Future<void> loadAllPosts() async {
    //get all posts from firbase
    final allPosts = await _db.getAllPostsFromFirebase();

    //update local data
    _allPosts = allPosts;

    //update UI
    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //delete post
  // Future<void> deletePost(String postId) async {
  //   //delete from firebase
  //   await _db.deletePostFromFirebase(postId);

  //   //reload data from firebase
  //   await loadAllPosts();
  // }
}
