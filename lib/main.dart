import 'package:chat/constants/serviceAccCred.dart';
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

/// headline TODOs
/// 1. fix dotenv not working ✅
/// 2. fix fb secret restricted ✅
/// 3. fix on notification click not naavigating to app ✅
/// 4. pass in the roomId in payload. 🧪 NEEDED ✅`
/// 5. fix calling. and handling states properly. 
/// 6. handle call end states

void main(List<String> args) async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceAccCred.intializeSecret();
  
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

