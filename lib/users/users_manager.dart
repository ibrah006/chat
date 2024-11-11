
import 'package:chat/databases/tables/chats.dart';
import 'package:chat/users/admin_user_info.dart';
import 'package:chat/users/person.dart';
import 'package:get/get.dart';

class UsersManager {

  static Future<Person?> searchUser(String email) async {
    if (email.isEmail) {
      final userInfo = await AdminUserInfo.getUserInfo(email);

      if (userInfo!=null) {
        // user found
        print("user's uid found: ${userInfo.uid}");

        return userInfo;
      }
    }
    return null;
  }

  static Future<Person?> addNewFriend(String email, {Person? userData}) async {

    if (userData!=null) {
      await ChatsTable.insert(ChatsTableRow(userData));
      return userData;
    }

    final userInfo = await searchUser(email);
    if (userInfo!=null) {
      await ChatsTable.insert(ChatsTableRow(userInfo));
      return userInfo;
    }

    
    return null;
  }

  static Future<String> updateUserFcmToken(String email) async {
    final updatedUserInfo = await AdminUserInfo.getUserInfo(email);

    if (updatedUserInfo != null) {
      ChatsTable.update(updatedUserInfo);

      return updatedUserInfo.fcmToken;
    } else {
      // for now it's develop feature so it's gonna throw an error if an invalid email / data not found. We're gonna just assume that there is an issue with the email that is passed in
      throw "Invalid EMAIL: (ASSUMPTION) invalid email &|| cannot get data for this email";
    }
  }

}