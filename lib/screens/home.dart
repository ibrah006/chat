
import 'package:audioplayers/audioplayers.dart';
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
 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE3F2FD),
        elevation: 0,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,).copyWith(top: 30),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),

            // "Recent Chats" section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Chats',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GetBuilder<FriendsController>(
                        builder: (context) {

                          final friends = friendsController.data;

                          return ListView.separated(
                            itemCount: friends.length, // example count for recent chats
                            separatorBuilder: (context, index) => Divider(
                              thickness: 1,
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                            itemBuilder: (context, index) {
                          
                              final Person friend = friends[index];
                              final String userFcmToken = friend.fcmToken;
                              final bool showFcmWarning = userFcmToken.isEmpty;
                                      
                              print("friend: ${friend.toMap()}");
                          
                              final lastMessage = friend.lastMessage;
                          
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade50,
                                  child: Icon(Icons.person, color: Colors.grey),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      '${friend.displayName?? "N/A display name"}${auth.currentUser!.uid == friend.uid? " (You)" : ""}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    ... showFcmWarning? [
                                      SizedBox(width: 13),
                                      Text("FCM TOKEN", style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                      Icon(Icons.warning_rounded, color: Colors.red.shade400)
                                    ] : []
                                  ],
                                ),
                                subtitle: lastMessage==null? null : Text(
                                  "${lastMessage.isSender? "You: " : ""}${lastMessage.text}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '12:34 PM',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (friend.lastMessage?.isRead == false)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade400,//Color(0xFFFF6B6B),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: SizedBox()
                                      ),
                                  ],
                                ),
                                onTap: () async {
                                  friendsController.updateLastMessageReadStatus(friend.uid!, true);
                                  await Get.toNamed("/chat", arguments: friend);
                                },
                              );
                            },
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start new chat action
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
  void refreshFcmToken(int index, String email) async {

    final updatedUserFcmToken = await UsersManager.updateUserFcmToken(email);
    final Person user = friendsController.data.elementAt(index);

    user.fcmToken = updatedUserFcmToken;
    
    friendsController.data[index] = user;
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