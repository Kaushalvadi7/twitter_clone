/*
-This converts a timestamp object in to a string

E.g.

If the input timestamp represents: July 28, 2025, 13:00

the function will return the string: "2025-07-24 14:30"

 */


import 'package:cloud_firestore/cloud_firestore.dart';

String getTimeAgo(Timestamp timestamp) {
  DateTime now = DateTime.now();
  DateTime dateTime = timestamp.toDate();
  Duration difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hr ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 30) {
    int weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}
