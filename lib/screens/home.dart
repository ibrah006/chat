
import 'package:audioplayers/audioplayers.dart';
import 'package:chat/components/minimal_tile.dart';
import 'package:chat/components/static/concepts.dart';
import 'package:chat/constants/date.dart';
import 'package:chat/constants/developer_debug.dart';
import 'package:chat/databases/local_database.dart';
import 'package:chat/databases/tables.dart';
import 'package:chat/services/notification/notification_service.dart' show handleMessage;
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/services/provider/state_controller/state_controller.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat/services/messages/message.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class HomeScreen extends MainWrapperStateful {

  final TextEditingController searchController = TextEditingController();

  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  late String fcmRadioOption;

  final DeveloperDebug debug = DeveloperDebug();

  final Stopwatch sinceStart = Stopwatch();

  final List<Message> messages = [];

  // for playing a small sound on notification while inside '/chat' screen
  final AudioPlayer audioPlayer = AudioPlayer();
  static const audioPath = "audio/bubble.mp3";

  // when a message comes in for the current user, it is stored inside this until read in the chat_screen
  final List<Message> messagesSource = [];

  final MessagesController messagesController = Get.put(MessagesController());
  
  final FriendsController friendsController = Get.put(FriendsController());

  @override
  void initState() {
    super.initState();

    // TODO: show a loading screen until this future is completed 
    LocalDatabase.get(Tables.chats).then((rawFriends) {
      setState(() {
        friendsController.data = Person.fromIterableMap(rawFriends).obs;
      });
    });

    // getting the remote message (notification) user clicked on to get to the app (if any)
    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage) {
      if (remoteMessage!=null) {
        print("invoked home screen initial message!, remoteMessage: ${remoteMessage.data}");
        handleMessage(remoteMessage);
      }
    });

    FirebaseMessaging.onMessage.listen((remoteMessage) {
      print("remote notification received while inside home screen: ${remoteMessage.data}");

      final formattedRemoteMessage = Message.fromMap(Map.of(remoteMessage.data));

      messagesSource.add(formattedRemoteMessage);
      if (Get.currentRoute != "/chat") {
        // play sound
        InAppNotification.show(formattedRemoteMessage);
        formattedRemoteMessage.isRead = false;
      }

      friendsController.updateLastMessage(formattedRemoteMessage);

      AudioPlayer().play(AssetSource(audioPath));
      messagesController.data.add(formattedRemoteMessage);
    });

    sinceStart.start();
  }

  @override
  void dispose() {
    super.dispose();

    sinceStart.stop();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[700]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: GetBuilder<FriendsController>(
        builder: (context) {
          final friends = friendsController.data;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12.5),
            children: List.generate(
              friendsController.data.length,
              (index) {
                final Person friend = friends[index];
          
                return _buildChatTile(
                  friend
                );
              }
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6C63FF),
        child: Icon(Icons.message, color: Colors.white),
        onPressed: () async {
          // Add new chat action
          Get.toNamed('/search');
          setState(() {});
        },
      ),
    );
  }

  void toChatScreenCallback(Person user) async {
    await Get.toNamed("/chat", arguments: user);
    setState(() {});
  }

  Widget _buildChatTile(Person user) {

    final bool showFcmWarning = user.fcmToken.isEmpty;

    if (showFcmWarning) {
      refreshFcmToken(user.email!).then((value) {
        setState(() {});
      });
    }

    return MinimalTile(user, profileImageUrl: "", chatScreenCallBack: toChatScreenCallback);

    // return GestureDetector(
    //   onTap: ()=> toChatScreenCallback(user),
    //   child: Container(
    //     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    //     padding: EdgeInsets.all(12.0),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(16.0),
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.grey.withOpacity(0.15),
    //           spreadRadius: 2,
    //           blurRadius: 8,
    //           offset: Offset(0, 4),
    //         ),
    //       ],
    //     ),
    //     child: Row(
    //       children: [
    //         Stack(
    //           children: [
    //             CircleAvatar(
    //               radius: 28,
    //               // backgroundImage: NetworkImage(avatarUrl),
    //             ),
    //             if (isOnline)
    //               Positioned(
    //                 bottom: 2,
    //                 right: 2,
    //                 child: Container(
    //                   width: 12,
    //                   height: 12,
    //                   decoration: BoxDecoration(
    //                     color: Colors.green,
    //                     shape: BoxShape.circle,
    //                     border: Border.all(color: Colors.white, width: 2),
    //                   ),
    //                 ),
    //               ),
    //           ],
    //         ),
    //         SizedBox(width: 12),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 children: [
    //                   Text(
    //                     name,
    //                     style: TextStyle(
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.w600,
    //                       color: Colors.black87,
    //                     ),
    //                   ),
    //                   if (showFcmWarning) ...[
    //                     SizedBox(width: 13),
    //                     Text("FCM TOKEN", style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 12.75)),
    //                     Icon(Icons.warning_rounded, color: Colors.red.shade400)
    //                   ]
    //                 ],
    //               ),
    //               SizedBox(height: 4),
    //               Text(
    //                 lastMessage!=null? "${lastMessage.isSender? "You: " : ""}${lastMessage.text}" : "Click here to start messaging",
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: TextStyle(
    //                   fontSize: 14,
    //                   color: Colors.grey[600],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             if (time!=null) Text(
    //               time,
    //               style: TextStyle(
    //                 fontSize: 12,
    //                 color: Colors.grey[500],
    //               ),
    //             ),
    //             if (user.lastMessage?.isRead == false) Column(
    //               crossAxisAlignment: CrossAxisAlignment.end,
    //               children: [
    //                 Text(
    //                   DateFormat("hh:mm a").format(lastMessage.datetime),
    //                   style: GoogleFonts.poppins(
    //                     fontSize: 12,
    //                     color: Colors.grey,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 4),
    //                 Container(
    //                   // padding: const EdgeInsets.all(4),
    //                   decoration: BoxDecoration(
    //                     color: Colors.red.shade400,//Color(0xFFFF6B6B),
    //                     borderRadius: BorderRadius.circular(8),
    //                   ),
    //                   child: Padding(padding: EdgeInsets.only(top: 4), child: SizedBox())
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void logout() async {
    await auth.signOut();
    Navigator.popAndPushNamed(context, "/login");
  }

  /// Debug purposes. Maybe useful but not to be implemented in the same way
  Future<void> refreshFcmToken(String email) async {

    final updatedUserFcmToken = await UsersManager.updateUserFcmToken(email);
    final Person user = friendsController.data.firstWhere((e) => e.email == email);

    user.fcmToken = updatedUserFcmToken;

    final int userIndex = friendsController.data.indexWhere((e)=> e.email == email);
    
    friendsController.data[userIndex] = user;
    setState(() {});
  }

  void addCallback() async {
    final searchUserEmail = searchController.text;

    final Person? userInfo = await UsersManager.addNewFriend(searchUserEmail);
    
    if (userInfo!=null) {
      friendsController.data.add(userInfo);

      setState(() {});
    }
  }
}

// ElevatedButton(
//             onPressed: () {
//               // NotificationService.showNotification(NotificationInfo("in-app notification", "sample in-app notification test", ));
//             },
//             child: Text("show notification"),
//           ),