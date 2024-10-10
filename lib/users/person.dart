

import 'package:chat/main.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Person implements NotificationInfo {
  Person(this.uid, this.email, {this.displayName, required this.fcmToken}) {
    if ((uid==null || email==null)) {
      debugErrorFromPast = true;

      displayName = "Previous Build Error";
      email = "This bug should be fixed once you clear the chats sqflite table.";
    } else if ((displayName?.split("%20%").length?? 1) > 1) {
      final displayNameFcmToken = displayName!.split("%20%");
      displayName = displayNameFcmToken[0];
      fcmToken = displayNameFcmToken[1];
    }
  }

  String? uid, email;
  String? displayName;

  bool debugErrorFromPast = false;

  static List<Person> fromIterableMap(List<Map<String, dynamic>> data) {
    return data.map((e)=> fromMap(e)).toList();
  }

  static Person fromMap(Map<String, dynamic> map) {

    print("Person (class): requested convert from map: $map");

    return Person(map["uid"]?? map["localId"], map["email"], displayName: map["displayName"], fcmToken: map["fcmToken"]?? "");
  }

  /// Get the Person instance for the current user from FirebaseAuth
  static Person fromFirebaseAuth(FirebaseAuth auth) {
    final currentUser = auth.currentUser!;
    final displayNameFCMToken = currentUser.displayName!.split("%20%");
    final currentUserDisplayName = displayNameFCMToken[0];
    final currentUserFcmToken = displayNameFCMToken[1];
    return Person(currentUser.uid, currentUser.email, fcmToken: currentUserFcmToken, displayName: currentUserDisplayName);
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "fcmToken": fcmToken
    };
  }

  @override
  String fcmToken;
  
  @override
  // TODO: implement body
  String get body => throw UnimplementedError();
  
  @override
  // TODO: implement title
  String get title => throw UnimplementedError();
  
  @override
  // TODO: implement type
  NotificationType get type => throw UnimplementedError();
}

// throw Exception("MANUALLY CAUGHT EXCEPTION: UID. maybe passing in debugErorrFromPast = true will fix the error. This is expected to be a temporary error and should be fixed after cleaning the chats table.");