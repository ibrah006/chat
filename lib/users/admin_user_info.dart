

import 'dart:convert';
import 'dart:io';

import 'package:chat/constants/serviceAccCred.dart';
import 'package:chat/users/person.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AdminUserInfo {

  static App? _adminApp;

static Future<Person?> getUserInfo(String email) async {
    /// parameter `getUserby` can be either uid and email. the function will detect it.
    
    final isEmail = email.isEmail;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/service-account.json');
    final data = jsonEncode(ServiceAccCred.secret); 
  
    await file.writeAsString(data);

    try {
      _adminApp??= FirebaseAdmin.instance.initializeApp(
        AppOptions(credential: FirebaseAdmin.instance.certFromPath(file.path)),
      );
    } catch(e) {
      _adminApp??= FirebaseAdmin.instance.initializeApp(
        AppOptions(credential: FirebaseAdmin.instance.certFromPath(file.path)),
        "second-instance"
      );
    }

    try {
      var v = await ( isEmail? _adminApp!.auth().getUserByEmail(email) : _adminApp!.auth().getUser(email));

      final Map<String, dynamic> formattedFriendData = _convertAdminFetchedUserInfo(
        // have to make a copy of this map so that changes can be made in the map otherwise we might get unmodifiable map error.
        Map.of(v.toJson())
      );
      print("requested friend info : $formattedFriendData");

      return Person.fromMap(formattedFriendData);
    } on FirebaseException catch (e) {
      print("error message: ${e.message}");
      return null;
    }
  }

  static Map<String, dynamic> _convertAdminFetchedUserInfo(Map<String, dynamic> adminUserInfo) {
    final userUid = adminUserInfo["localId"];

    // catching an error when user tries to add a users who have signed up but not yet set thier display name / fcm token
    //TODO: urgent- set display name to "$displayName%20%$fcmToken"
    try {
      final displayNameFCMToken = adminUserInfo["displayName"].toString().split("%20%");
      final displayName = displayNameFCMToken[0];
      final fcmToken = displayNameFCMToken[1];

      adminUserInfo["displayName"] = displayName;
      adminUserInfo["fcmToken"] = fcmToken;
    } on RangeError {}

    adminUserInfo["uid"] = userUid;
    adminUserInfo.remove("localId");

    return adminUserInfo as Map<String, dynamic>;
  }

}