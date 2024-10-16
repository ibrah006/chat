

import 'dart:convert';

import 'package:chat/main.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

@pragma("vm:entry-point")
Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  if (message!=null) {
    print("new message: ${message.from}, ${message.data}, ${message.messageId}");
    handleMessage(message);
  }
}

void handleMessage(RemoteMessage message) {
  // notification pressed

  print("noti pressed: ${message.data}");

  //TODO: check to see if it's a call notification before executing the below

  final payload = Map.of(message.data);
  payload["isCaller"] = false;

  print("payload received: $payload");

  Get.toNamed("/call", arguments: payload);
}

class NotificationService {

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