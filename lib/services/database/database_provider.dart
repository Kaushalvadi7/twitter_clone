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

  //update edit profile
  Future<void> updateUserProfile({
    required String name,
    required String username,
    String? profileImageUrl,
    String? birthDate,
  }) =>
      _db.updateUserProfileFirebase(
        name: name,
        username: username,
        profileImageUrl: profileImageUrl,
        birthDate: birthDate,
      );


  /*
  Posts
   */

  //local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  //get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  //post message
  Future<void> postMessage(String message, {String? imageUrl}) async {
    //post message in firebase
    await _db.postMessageInFirebase(message,  imageUrl: imageUrl);

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

    //filter out the following posts
    await loadFollowingPosts();

    //initial local like data
    initializedLikeMap();

    //update UI
    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //load following posts -> posts from users that the current user follows
  Future<void> loadFollowingPosts() async {
    //get current user id
    String currentUserid = _auth.getCurrentUserid();

    //get list of uids that the current logged in user follows (from firebase)
    final followingUserIds = await _db.getFollowingUidsFromFirebase(
      currentUserid,
    );

    //filter all posts to be the onces for the following tab

    _followingPosts =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();

    //update UI
    notifyListeners();
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
  bool isFollowing(String uid) {
    //get current uid
    final currentUserId = _auth.getCurrentUserid();

    //if current user is in target user's followers list
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  /*
  Map of profiles

  for a given uid:

  -list of follower profiles
  -list of following profiles

   */

  final Map<String, List<UserProfile>> _followersProfiles = {};
  final Map<String, List<UserProfile>> _followingProfiles = {};

  //get list of follower profiles for a given user
  List<UserProfile> getListOfFollowersProfiles(String uid) =>
      _followersProfiles[uid] ?? [];

  //get list of following profiles for a given user
  List<UserProfile> getListOfFollowingProfiles(String uid) =>
      _followingProfiles[uid] ?? [];

  //load follower profiles for a given user
  Future<void> loadUserFollowerProfiles(String uid) async {
    try {
      //get list of follower uids from firebase
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      //create list of user profiles
      List<UserProfile> followerProfiles = [];

      //go through each follower id
      for (String followerId in followerIds) {
        //get user profile from firebase with this uid
        UserProfile? followerProfile = await _db.getUserFromFirebase(
          followerId,
        );

        //add to follower profiles list
        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }
      // update local data
      _followersProfiles[uid] = followerProfiles;

      //update UI
      notifyListeners();
    }
    // if there are errors..
    catch (e) {
      print(e);
    }
  }

  //load following profiles for a given user
  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      //get list of following uids from firebase
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      //create list of user profiles
      List<UserProfile> followingProfiles = [];

      //go through each following id
      for (String followingId in followingIds) {
        //get user profile from firebase with this uid
        UserProfile? followingProfile = await _db.getUserFromFirebase(
          followingId,
        );

        //add to following profiles list
        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }

      //update local data
      _followingProfiles[uid] = followingProfiles;

      //update ui
      notifyListeners();
    }
    //if there is an error
    catch (e) {
      print(e);
    }
  }

  /*
  SEARCH USERS
 */

  // list of search results
  List<UserProfile> _searchResults = [];

  //get list of search results
  List<UserProfile> get searchResults => _searchResults;

  //method to search for a user
  Future<void> searchUsers(String searchTerm) async {
    try {
      //search users in firebase
      final results = await _db.searchUsersInFirebase(searchTerm);

      //update local data
      _searchResults = results;

      //update ui
      notifyListeners();
    }
    //errors.
    catch (e) {
      print(e);
    }
  }
}
