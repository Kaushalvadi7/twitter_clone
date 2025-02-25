import 'package:flutter/foundation.dart';
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
}
