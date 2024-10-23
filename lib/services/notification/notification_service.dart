

import 'dart:convert';

import 'package:chat/main.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/users/users_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:chat/services/messages/message.dart' as message;

@pragma("vm:entry-point")
Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  if (message!=null) {
    print("new message: ${message.from}, ${message.data}, ${message.messageId}");
    handleMessage(message);
  }
}

void handleMessage(RemoteMessage remoteMessage) {
  // notification pressed

  final msg = message.Message.fromMap(remoteMessage.data);
  if (msg.details.roomId != null) {
    NotificationService.onAnswerCall(remoteMessage.data);
  } else {
    // TODO: handle on press notification for non-calls
  }
}

class NotificationService {

  static onAnswerCall(Map<String, dynamic> messagePayload) async {
    print("noti pressed: ${messagePayload}");

    //TODO: check to see if it's a call notification before executing the below

    final payload = Map<String, dynamic>.of(messagePayload);
    payload["isCaller"] = false;

    print("payload received: $payload");

    final message.Message messageRecevied = message.Message.fromMap(messagePayload);

    // adds this friend to chats table if they doesn't already exsist
    await UsersManager.addNewFriend(messageRecevied.details.email!, userData: messageRecevied.details);

    Get.toNamed("/call", arguments: payload);
  }

  static final _firebaseMessaging = FirebaseMessaging.instance;

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: "This Channel is used for high importance notifications",
    importance: Importance.max
  );

  static final _androidNotificationDetails = AndroidNotificationDetails(
    _androidChannel.id,
    _androidChannel.name,
    channelDescription: _androidChannel.description,
    icon: '@drawable/ic_launcher'
  );

  static Future<String> intializeNotification() async {

    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    currentDeviceFCMToken = fcmToken!;

    initPushNotifications();

    initLocalNotifications();

    return fcmToken;
  }

  static Future<void> initPushNotifications() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );

    _firebaseMessaging.getInitialMessage().then(handleBackgroundMessage);
  
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  static Future initLocalNotifications() async {
    // const iOS = IOSInitializationSettings;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings("@drawable/ic_launcher"),
      iOS: DarwinInitializationSettings()
    );


    // initilize local notifications
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        handleMessage(
          RemoteMessage.fromMap(jsonDecode(details.payload?? "{}"))
        );
      },
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    platform?.createNotificationChannel(_androidChannel);
  }

  static void _onDidReceiveBackgroundNotificationResponse(details) {
    handleBackgroundMessage(
      RemoteMessage.fromMap(jsonDecode(details.payload?? "{}"))
    );
  }

  static Future<void> showNotification(NotificationInfo notiInfo) async {
    _localNotifications.show(
      0,
      notiInfo.title,
      notiInfo.body,
      NotificationDetails(android: _androidNotificationDetails)
    );
  }

}

// _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: _androidNotificationDetails
//         ),
//         payload: jsonEncode(message.toMap())
//       );