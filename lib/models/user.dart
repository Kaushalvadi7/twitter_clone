import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String? profileImageUrl;
  final String? birthDate;
  final String? joinedDate;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    this.profileImageUrl,
    this.birthDate,
    this.joinedDate,
  });

  /* 
  firebase -> app

  convert firestore document to user profile (so that we can use in our app)
  */
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      profileImageUrl: doc['profileImageUrl'],
      birthDate: doc['birthDate'],
      joinedDate: doc['joinedDate'],

    );
  }

  /*
  app -> firebase

  covert a user profile to a map(so that we can store in firebase)
   */
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'birthDate': birthDate,
      'joinedDate': joinedDate,
    };
  }
}
