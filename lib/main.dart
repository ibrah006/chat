import 'package:chat/screens/call.dart';
import 'package:chat/screens/chat.dart';
import 'package:chat/screens/home.dart';
import 'package:chat/screens/login.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/firebase_options.dart';
import 'package:chat/services/notification/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

const ROOMOWNER = 'mohammed';
const CALLTYPE = CallType.video;

late final String currentDeviceFCMToken;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final String fcmToken = await NotificationService.intializeNotification();

  //TODO: remove this when shifitng to call screen
  await Permission.camera.request();

  runApp(GetMaterialApp(
    theme: ThemeData(
      useMaterial3: false
    ),
    navigatorKey: navigatorKey,
    // home: HomeScreen(),
    initialRoute: '/login',
    getPages: [
      GetPage(name: "/", page: ()=> HomeScreen()),
      GetPage(name: "/login", page: ()=> LoginScreen(fcmToken)),
      GetPage(name: "/call", page: ()=> CallScreen()),
      GetPage(name: "/chat", page: ()=> ChatScreen())
    ],
  ));
}

