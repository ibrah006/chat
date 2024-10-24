
import 'package:audioplayers/audioplayers.dart';
import 'package:chat/constants/date.dart';
import 'package:chat/constants/developer_debug.dart';
import 'package:chat/constants/dialogs.dart';
import 'package:chat/databases/local_database.dart';
import 'package:chat/databases/tables.dart';
import 'package:chat/main.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/notification/notification_service.dart' show handleMessage;
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/services/provider/state_controller/messages_controller.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat/components/custom_radios.dart';
import 'package:chat/services/messages/message.dart';

class HomeScreen extends MainWrapperStateful {

  final TextEditingController searchController = TextEditingController();

  List<Person> friends = [];

  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  late String fcmRadioOption;

  final DeveloperDebug debug = DeveloperDebug();

  final Stopwatch sinceStart = Stopwatch();

  final List<Message> messages = [];

  // for playing a small sound on notification while inside '/chat' screen
  final AudioPlayer audioPlayer = AudioPlayer();
  static const audioPath = "bubble.mp3";

  // when a message comes in for the current user, it is stored inside this until read in the chat_screen
  final List<Message> messagesSource = [];

  final MessagesController messagesController = Get.put(MessagesController());

  @override
  void initState() {
    super.initState();

    // TODO: show a loading screen until this future is completed 
    LocalDatabase.get(Tables.chats).then((rawFriends) {
      setState(() {
        friends = Person.fromIterableMap(rawFriends);
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
        InAppNotification.show(formattedRemoteMessage );
      } else {
        // play sound
        audioPlayer.play(AssetSource(audioPath));
        
      }
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
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout))
        ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                ),
              ),
              IconButton(
                onPressed: addCallback,
                icon: Icon(Icons.add)
              )
            ],
          ),
          Expanded(
            child: CustomRadios(
              onChanged: (index) {
                fcmRadioOption = friends[index].fcmToken;
              },
              children: List.generate(
                friends.length,
                (index) {
                  
    
                  final Person friend = friends[index];
                  final String userFcmToken = friend.fcmToken;
                  final bool showFcmWarning = userFcmToken.isEmpty;
    
                  print("friend: ${friend.toMap()}");
    
                  return ListTile(
                    leading: !true? null : Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Text("FCM", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: TextButton(
                            style: ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: WidgetStatePropertyAll(Size.zero),
                              padding: WidgetStatePropertyAll(EdgeInsets.zero)
                            ),
                            onPressed: ()=> refreshFcmToken(index, friend.email!),
                            child: Icon(Icons.refresh_rounded,),
                          )
                        )
                      ],
                    ),
                    title: Row(
                      children: [
                        Text('${friend.displayName?? "N/A display name"}${auth.currentUser!.uid == friend.uid? " (You)" : ""}'),
                        ... showFcmWarning? [
                          SizedBox(width: 13),
                          Text("FCM TOKEN", style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          Icon(Icons.warning_rounded, color: Colors.red.shade400)
                        ] : []
                      ],
                    ),
                    subtitle: Text(friend.email.toString()),
                    onTap: () {
                      Get.toNamed("/chat", arguments: friend);
                    },
                    trailing: IconButton(
                      onPressed: () {
                        // send notifcation about the call
                  
                        Get.toNamed(
                          "/call",
                          arguments: CallDetails.fromUserInfo(friend, CALLTYPE).toMap()
                        );
                  
                        //sendFCMMessage();
                        
                        // TODO: send this notification after intiating the call
                      },
                      icon: Icon(Icons.video_call_rounded),
                    ),
                  );
                }
              )
            )
          ),

          ListTile(
            leading: Checkbox(
              value: debug.showTimeSinceStart,
              onChanged: (newValue)=> setState(() {
                debug.toggleShowTimeSinceStart(newState: newValue);
              })
            ),
            title: Text("${debug.showTimeSinceStart? "Hide" : "Show"} time since.", style: TextStyle(fontSize: 12.5),),
            trailing: debug.showTimeSinceStart? Text(DateManager.getDuration(sinceStart.elapsed)) : null
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  throw UnimplementedError("This method's functionality has been turned off temporarily");
                  // SendPushNotification().sendNotification(
                  //   info: NotificationInfo(
                  //     "Sample notification title", "sample body", fcmRadioOption, type: NotificationType.call
                  //   ),
                  //   details: Person("sample", "sample@mail.com", fcmToken: fcmRadioOption)
                  // );
                },
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
                  minimumSize: WidgetStatePropertyAll(Size.zero)
                ),
                child: Text("Send FCM notification", style: TextStyle(fontSize: 12.5),)
              ),
              // show/hide time since checkbox
              PopupMenuButton(
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.developer_mode_rounded),
                    Text("Developer options"),
                  ],
                ),
                onSelected: (value) {},
                itemBuilder: (BuildContext context) {
                  return List<PopupMenuEntry<int>>.generate(
                    1, (index) {
              
                      final option = ['Delete databases'][index];
              
                      return PopupMenuItem<int>(
                        value: index,
                        child: ListTile(
                          dense: true,
                          leading: [
                            Icon(Icons.dataset),
                          ][index],
                          contentPadding: EdgeInsets.zero,
                          onTap: () async {
                            final positiveClicked = await Dialogs.showAlertDialog(
                              context,
                              title: "Developer Action",
                              body: 'Are you sure you want to dispatch "$option"',
                              positiveText: "Yes",
                            );
              
                            print("positive Cliked: $positiveClicked");
              
                            if (positiveClicked) {
                              await DeveloperDebug.runOptions(index);
                            }
                          },
                          title: Text(option),
                        ),
                      );
                    }
                  );
                },
              ),
            ],
          )
        ],
      )
    );
  } 

  void logout() async {
    await auth.signOut();
    Navigator.popAndPushNamed(context, "/login");
  }

  /// Debug purposes. Maybe useful but not to be implemented in the same way
  void refreshFcmToken(int index, String email) async {

    final updatedUserFcmToken = await UsersManager.updateUserFcmToken(email);
    final Person user = friends.elementAt(index);

    user.fcmToken = updatedUserFcmToken;
    
    friends[index] = user;
    setState(() {});
  }

  void addCallback() async {
    final searchUserEmail = searchController.text;

    final Person? userInfo = await UsersManager.addNewFriend(searchUserEmail);
    
    if (userInfo!=null) {
      friends.add(userInfo);

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