/* POST MODEL
This is what every post should have.
*/
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id; // id of this post
  final String uid; //uid of the poster
  final String name; //name of the poster
  final String username; //username of poster
  final String message; //message of the post
  final Timestamp timestamp; //timestamp of the post
  final int likeCount; // like count of this post
  final List<String> likedBy; //list of user Ids who liked this post
  final String? imageUrl;
  final String? profileImageUrl;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
    this.imageUrl,
    this.profileImageUrl,
  });

  //Convert a Firebase document to a Post object (to use in our app)
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      likeCount: doc['likes'],
      likedBy: List<String>.from(doc['likedBy'] ?? []),
      imageUrl: doc['imageUrl'], // may be null if not present
      profileImageUrl: doc['profileImageUrl'],
    );
  }

  //convert a post object to a map (to store in firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likes': likeCount,
      'likedBy': likedBy,
      'imageUrl': imageUrl,
      'profileImageUrl': profileImageUrl,
    };
  }
}
