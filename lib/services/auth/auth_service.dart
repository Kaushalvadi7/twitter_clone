import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/services/database/database_service.dart';

class AuthService {
  //get instance of firebase auth
  final _auth = FirebaseAuth.instance;

  //get current user & userid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUserid() => _auth.currentUser!.uid;

  //Login -> with Email & Password
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    //attempt login
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    }
    //catch any errors...
    on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  //Register -> with Email & Password
  Future<UserCredential> registerEmailPassword(
    String email,
    String password,
  ) async {
    //attempt to register new user
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    //catch any errors...
    on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // 🔹 Send Password Reset Email
  // Future<void> sendPasswordResetEmail(String email) async {
  //   try {
  //     await _firebaseAuth.sendPasswordResetEmail(email: email);
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(_getAuthErrorMessage(e));
  //   }
  // }

  // 🔹 logout
  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  //delete account
  Future<void> deleteAccount() async {
    //get current user
    User? user = getCurrentUser();

    if (user != null) {
      //delete user's data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      //delete user's account
      await user.delete();
    }
  }

  // 🔹 Helper method for error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
