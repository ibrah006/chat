import 'dart:convert';
import 'package:chat/constants/notifications_c.dart';
import 'package:chat/constants/serviceAccCred.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/services/notification/notification_service.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:overlay_support/overlay_support.dart';


class SendPushNotification {

  // Replace this with your actual project ID
  static const String projectId = 'flash-chat-72eca';

  // Get Access Token using the service account key
  Future<String> _getAccessToken(String deviceFcmToken) async {

    var credentials = ServiceAccountCredentials.fromJson(ServiceAccCred.secret);

    var scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    final client = http.Client();
    final authClient = await clientViaServiceAccount(credentials, scopes);

    var token = await authClient.credentials.accessToken;
    client.close();

    return token.data;
  }

  /// returns if fcmToken (and updates friends table) for specified user has been updated otherwise returns null. 
  static Future<String?> getUpdatedFcmToken(friendUid, friendEmail) async {
    final currentUUid = FirebaseAuth.instance.currentUser!.uid;

    final userUpdatesPath = FirebaseFirestore.instance.collection("updates").doc(friendUid);
    final docGet = await userUpdatesPath.get();
    if (docGet.exists) {
      final readsDoc = userUpdatesPath.collection("reads").doc(currentUUid);
      final hasReadBefore = (await readsDoc.get()).exists;

      if (!hasReadBefore) {
        // update fcmToken for user in friends table
        final updatedUserFcmToken = await UsersManager.updateUserFcmToken(friendEmail);
        // add to reads
        await userUpdatesPath.collection("reads").doc(currentUUid).set({});

        return updatedUserFcmToken;
      }
    }
    return null;
  }

  static checkFriendsFcmToken(uid, displayName, fcmToken) async {

    final query = FirebaseFirestore.instance.collection("updates").limit(1).where("data", isEqualTo: "$displayName%20%$fcmToken");

    print("response data isBlack: ${query.isBlank}");
    try {
      print("this is the reposnse received ${DateTime.now().toString()}: ${(await query.limit(1).get()).docs.first.data()}");
    } catch(e) {
      print("this is the response received: <no element>");
    }
    // print("this is the reposnse received: ${(await query.get()).docChanges}");
  }

  // Send notification using the FCM HTTP v1 API
  Future<void> sendNotification({required NotificationInfo info, required final Message message}) async {
    String accessToken = await _getAccessToken(info.fcmToken!);

    var url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    Map<String, dynamic> body = NotificationConstants.getNotificationPayload(
      info, data: message.toMap()
    );

    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };


    print("about to send message notification: ${message.toMap()}");

    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    int resendCount = 0;

    if (response.statusCode == 200) {
      print('Notification sent successfully: ${response.body}');
    } else {
      if (resendCount <= 5) throw "Failed Sending Notification: status_code = ${response.statusCode}, ${response.body}";
      resendCount++;
      print("Message not sent: ${response.statusCode} ${response.body}");
      // the fcm token might not be registered
      final updatedPerson = await UsersManager.searchUser(info.email);
      
      if (updatedPerson != null) {
        print("initial Fcm token vs new: ${message.details.fcmToken}, ${updatedPerson.fcmToken}");

        message.details = message.details.copyFrom(updatedPerson);

        await sendNotification(info: info, message: message);
      } else {
        // FATAL ERROR
        print('Failed to send notification: ${response.statusCode} ${response.body}');
      }
    }
  }

}

class NotificationInfo {
  const NotificationInfo(this.title, this.body, this.fcmToken, {required this.type, required this.email});

  final String? fcmToken;

  final String title, body;
  final NotificationType type;
  // The email of the user who is to receive the message
  final String email;
}


class InAppNotification {

  static _toChatScreen(context, Message message) async {
    OverlaySupportEntry.of(context)?.dismiss();

    // check to see if user is already in chatscreen
    if (Get.currentRoute == "/chat") {
      final Person currentViewingChat = Get.arguments;
      // if the notification they clicked on is from a different friend than the currently viewing one, it will pop the screen and push chat screen again with the arguments corssponding to the notification's sender
      if (currentViewingChat.uid != message.details.uid) {
        Get.offNamed("/chat", arguments: message.details);
      }
    } else {
      Get.toNamed("/chat", arguments: message.details);
    }

    // adds friend to the table if doesn't already exist
    await UsersManager.addNewFriend(message.details.email!, userData: message.details);
  }

  static show(Message message) {
    
    final isCallNotification = message.details.roomId != null;

    showOverlayNotification(
      (context) {
        return SafeArea(
          child: GestureDetector(
            onTap: () async {
              _toChatScreen(context, message);
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Caller Info Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.details.displayName?? message.details.email!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isCallNotification? 'Incoming Call' : message.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Action Buttons
                  isCallNotification? Row(
                    children: [
                      // Decline Button
                      IconButton(
                        icon: Icon(Icons.call_end, color: Colors.red),
                        onPressed: () {
                          OverlaySupportEntry.of(context)?.dismiss();
                        },
                      ),
                      SizedBox(width: 10),
                      // Answer Button
                      IconButton(
                        icon: Icon(Icons.call, color: Colors.green),
                        onPressed: () {
                          NotificationService.onAnswerCall(message.toMap());
                          OverlaySupportEntry.of(context)?.dismiss();
                        },
                      ),
                    ],
                  ) : IconButton(
                    icon: Icon(Icons.reply_rounded, color: Colors.grey.shade500),
                    onPressed: ()=> null//_toChatScreen(context, message),
                  )
                ],
              ),
            ),
          ),
        );
      },
      duration: Duration(seconds: 10),
      // Text(
      //   message.details.displayName?? message.details.email!,
      //   style: const TextStyle(
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,
      //     color: Colors.black
      //   )),
      // subtitle: Text(
      //   isCallNotification? "Incoming Call" : message.text, style: const TextStyle(
      //     fontSize: 14,
      //     color: Colors.grey
      //   )),
      // background: Colors.white,
      // autoDismiss: false,
      // leading: CircleAvatar(
      //   radius: 24,
      //   backgroundColor: Colors.blue,
      //   child: Icon(
      //     isCallNotification? Icons.phone : Icons.person_rounded,
      //     color: Colors.white,
      //   ),
      // ),
      // trailing: Builder(
      //   builder: (context) {
      //     return isCallNotification? Wrap(
      //       children: [
      //         // Decline Button
      //         IconButton(
      //           icon: Icon(Icons.call_end, color: Colors.red),
      //           onPressed: () {
      //             OverlaySupportEntry.of(context)?.dismiss();
      //           },
      //         ),
      //         SizedBox(width: 10),
      //         // Answer Button
      //         IconButton(
      //           icon: Icon(Icons.call, color: Colors.green),
      //           color: Colors.green,
      //           onPressed: () {
      //             NotificationService.onAnswerCall(message.toMap());
      //             OverlaySupportEntry.of(context)?.dismiss();
      //           },
      //         ),
      //       ],
      //     ) : IconButton(
      //       icon: Icon(Icons.reply_rounded, color: Colors.grey.shade500),
      //       onPressed: () {},
      //     );
      //   },
      // ),
    );
  }

}