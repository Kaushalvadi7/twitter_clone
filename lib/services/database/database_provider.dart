import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:twitter_clone/models/comment.dart';
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
    //get all posts from firebase
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
    Now let's try to update it in our database
     */

    //attempt like in database
    try {
      await _db.toggleLikeInFirebase(postId);
    }
    // revert back to initial state if update fails
    catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      //update Ui again
      notifyListeners();
    }
  }

  /*
  Comments
  {
    postId1: [comment1, comment2, ..],
    postId2: [comment1, comment2, ..],
    postId3: [comment1, comment2, ..],

  }
  * */

  //local list of comments
  final Map<String, List<Comment>> _comments = {};

  //get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  //fetch comments from database for a post
  Future<void> loadComments(String postId) async {
    //get all comments for this post
    final allComments = await _db.getCommentsFromFirebase(postId);

    //update local data
    _comments[postId] = allComments;

    //update UI
    notifyListeners();
  }

  //add a comment
  Future<void> addComment(String postId, message) async {
    //add comments in firebase
    await _db.addCommentInFirebase(postId, message);

    //reload comments
    await loadComments(postId);
  }

  //delete a comments
  Future<void> deleteComment(String commentId, postId) async {
    //delete comment in firebase
    await _db.deleteCommentInFirebase(commentId);

    //reload comments
    await loadComments(postId);
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

  /*
Follow

Everything here is done with uids (String)
-----------------------------------------------------------------------------------

Each user id has a list of:
  - followers uid
  -following uid

  E.g.
  {
  'uid1' : [ list of uids that are followers / following],
  'uid2' : [ list of uids that are followers / following],
  'uid3' : [ list of uids that are followers / following],
  'uid4' : [ list of uids that are followers / following],

  }
 */

  //local map
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  //get counts for followers & following locally: given a uid
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;

  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  //load followers
  Future<void> loadUserFollowers(String uid) async {
    //get the list of follower uids from firebase
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    //update local data
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    //update ui
    notifyListeners();
  }

  //load following
  Future<void> loadUserFollowing(String uid) async {
    //get the list of following uids from firebase
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    //update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    //update ui
    notifyListeners();
  }

  //follow user
  Future<void> followUser(String targetUserId) async {
    /*
    currently logged in user want to follow target user
     */
    //get current uid
    final currentUserId = _auth.getCurrentUserid();

    // initialize with empty lists if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    /*
  Optimistic Ui changes: Update the local data & revert back if database request fails

   */

    //follow if current user is not one of the target user's followers
    if (!_followers[targetUserId]!.contains(currentUserId)) {
      //add current user to target user's follower list
      _followers[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //then add target user to current user following
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }
    //update UI

    notifyListeners();

    /*
    Ui has been optimistically update above with local data.
    Now let's try to make this request to our database.
     */
    try {
      //follow user in firebase
      await _db.followUserInFirebase(targetUserId);

      //reload current user's followers
      await loadUserFollowers(currentUserId);

      //reload current user's following
      await loadUserFollowing(currentUserId);
    } //if there is an error.. revert back to original
    catch (e) {
      //remove current user from target user's followers
      _followers[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      //remove from current user's following
      _following[currentUserId]?.remove(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      //update Ui
      notifyListeners();
    }
  }

  //unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    /*
    currently logged in user want to unfollow target user
     */

    //get current uid
    final currentUserId = _auth.getCurrentUserid();

    // initialize with empty lists if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    //unfollow if current user is one of the target user's following
    if (_followers[targetUserId]!.contains(currentUserId)) {
      //remove current user from target user's follower list
      _followers[targetUserId]?.remove(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

      //then remove target user from current user's following
      _following[currentUserId]?.remove(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }
    // update UI
    notifyListeners();

    //try to make this request to our database
    try {
      //unfollow target user in firebase
      await _db.unFollowUserInFirebase(targetUserId);

      //reload current user's followers
      await loadUserFollowers(currentUserId);

      //reload current user's following
      await loadUserFollowing(currentUserId);
    }
    //if there is an error.. revert back to original
    catch (e) {
      //add current user back to target user's followers
      _followers[targetUserId]?.add(currentUserId);

      //update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      //add target user back into current user's following list
      _following[currentUserId]?.add(targetUserId);

      //update following count
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      //update UI
      notifyListeners();
    }
  }

  //check if current user is following target user
  bool isFollowing(String targetUserId) {
    //get current uid
    final currentUserId = _auth.getCurrentUserid();

    //if current user is in target user's followers list
    return _followers[targetUserId]?.contains(currentUserId) ?? false;
  }

}
