
import 'package:audioplayers/audioplayers.dart';
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


import '../extensions.dart';

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
 

    return true? Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 6,
            colors: [
              Color(0xFFE3F2FD), // Light blue for gradient effect
              Color(0xFFFFFFFF), // White for subtle transition
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(child: SizedBox(height: 20)),

            // Welcome Title
            Text(
              'Chat',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              "Hi, ${auth.currentUser!.displayName?.split("%20%")[0].toCapitalized?? auth.currentUser!.email}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 28),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 21),

            // Chat List
            Expanded(
              child: GetBuilder<FriendsController>(
                builder: (context) {
                  final friends = friendsController.data;
                  return ListView.builder(
                    itemCount: friends.length, // Example count, replace with dynamic count
                    itemBuilder: (context, index) {
                                  
                      final Person friend = friends[index];
                      final String userFcmToken = friend.fcmToken;
                      final bool showFcmWarning = userFcmToken.isEmpty;
                              
                      print("friend: ${friend.toMap()}");
                  
                      final lastMessage = friend.lastMessage;

                      if (showFcmWarning) {
                        refreshFcmToken(friend.email!).then((value) {
                          setState(() {});
                        });
                      }
                                  
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed("/chat", arguments: friend);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(Icons.person, color: Colors.grey[400]),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${friend.displayName!}${friend.uid == auth.currentUser!.uid? " (You)" : ""}",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (showFcmWarning) ...[
                                            SizedBox(width: 13),
                                            Text("FCM TOKEN", style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                            Icon(Icons.warning_rounded, color: Colors.red.shade400)
                                          ]
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastMessage!=null? "${lastMessage.isSender? "You: " : ""}${lastMessage.text}" : "Click here to start messaging",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                if (friend.lastMessage?.isRead == false) Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat("hh:mm a").format(lastMessage!.datetime),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      // padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,//Color(0xFFFF6B6B),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(padding: EdgeInsets.only(top: 4), child: SizedBox())
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add new chat action
          Get.toNamed('/search');
          setState(() {});
        },
        backgroundColor: Color(0xFFFF6B6B),
        child: Icon(Icons.chat, color: Colors.white),
      ),
    ) : Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130), // Adjust the height as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(child: SizedBox()),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF247ff1),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: Colors.black87),
                        onPressed: () {
                          // Notification action
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.account_circle, color: Colors.black87, size: 30),
                        onPressed: () {
                          // Profile action
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Space between title and search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.03),
                      blurRadius: 23.5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
      
          // "Recent Chats" section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Chats',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
               
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/search");
        },
        backgroundColor: Color(0xFFFF6B6B),
        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
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