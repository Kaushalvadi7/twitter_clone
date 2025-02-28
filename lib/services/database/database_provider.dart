import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
import 'package:twitter_clone/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  /*
  SERVICES

  */

  //get db & auth service
  final _db = DatabaseService();
  final _auth = AuthService();

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

    //get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //filter out blocked user posts & update locally
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    //initial local like data
    initializedLikeMap();

    //update UI
    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // delete post
  Future<void> deletePost(String postId) async {
    //delete from firebase
    await _db.deletePostFromFirebase(postId);

    //reload data from firebase
    await loadAllPosts();
  }

  /*
  Likes */

  //local map to track like counts for each post
  Map<String, int> _likeCounts = {
    //for each post id: like count
  };

  //local list to track posts liked by current user
  List<String> _likedPosts = [];

  //does current user like this post?
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  // get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  //initalize like map locally
  void initializedLikeMap() {
    //get current uid
    final currentUserId = _auth.getCurrentUserid();

    //clear liked posts(for when new user signs in, clear local data)
    _likedPosts.clear();

    //for each post get like data
    for (var post in _allPosts) {
      //update like count map
      _likeCounts[post.id] = post.likeCount;

      //if the current user already likes this post
      if (post.likedBy.contains(currentUserId)) {
        //add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postId) async {
    /*

    This first part will update the local value first so that the UI feels immediate and responsive. We will update the UI optimisistically, Otherwise it takes some time(1-2 seconds, depending on the internet connection)

     */

    //store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    //perform like / unlike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    //update UI locally
    notifyListeners();
    /*
    Now let's try to update itin our database
     */

    //attempt like in database
    try {
      await _db.toggleLikeInFirebase(postId);
      await loadAllPosts();
    }
    // revert back to initial stste if update fails
    catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      //update Ui again
      notifyListeners();
    }
  }

  /*
Account Stuff
   */

  //local list of blocked users
  List<UserProfile> _blockedUser = [];

  //get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUser;

  //fetch blocked users
  Future<void> loadBlockedUsers() async {
    //get list of blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //get full user details using uid
    final blockedUserData = await Future.wait(
      blockedUserIds.map((id) => _db.getUserFromFirebase(id)),
    );

    //return as a list
    _blockedUser = blockedUserData.whereType<UserProfile>().toList();

    // update ui
    notifyListeners();
  }

  //block user
  Future<void> blockUser(String postUserId) async {
    //perform block in firebase
    await _db.blockUserInFirebase(postUserId);

    //reload blocked users
    await loadBlockedUsers();

    //reload data
    await loadAllPosts();

    //update ui
    notifyListeners();
  }

  //unblock user
  Future<void> unblockUser(String blockedUserId) async {
    //perform unblock in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    //reload blocked users
    await loadBlockedUsers();

    //reload posts
    await loadAllPosts();

    //update ui
    notifyListeners();
  }

  //Report user & post
  Future<void> reportUser(String postId, postUserId) async {
    //perform unblock in firebase
    await _db.reportUserInFirebase(postId, postUserId);
  }
}
