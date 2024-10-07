

import 'package:chat/constants/developer_debug.dart';
import 'package:chat/constants/dialogs.dart';
import 'package:chat/databases/local_database.dart';
import 'package:chat/databases/tables.dart';
import 'package:chat/main.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends MainWrapperStateful {

  final TextEditingController searchController = TextEditingController();

  List<Person> friends = [];

  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

  late String fcmRadioOption;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // TODO: show a loading screen until this future is completed 
    LocalDatabase.get(Tables.chats).then((rawFriends) {
      setState(() {
        friends = Person.fromIterableMap(rawFriends);
      });
    });

    
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
            child: ListView(
              children: List.generate(
                friends.length,
                (index) {
                  

                  final Person friend = friends[index];
                  final String userFcmToken = friend.fcmToken;
                  final bool showFcmWarning = userFcmToken.isEmpty;

                  if (index==0) fcmRadioOption = userFcmToken;

                  print("friend: ${friend.toMap()}");

                  return ListTile(
                    leading: Wrap(
                      children: [
                        //
                        Radio<String>(
                          value: userFcmToken,
                          groupValue: fcmRadioOption,
                          onChanged: (value) {
                            setState(() {
                              fcmRadioOption = value!;
                            });
                          },
                        ),
                        // FCM debug option
                        ... showFcmWarning? [Stack(
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
                        )] : []
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(friend.displayName?? "N/A display name"),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  SendPushNotification().sendNotification(
                    info: NotificationInfo(
                      "Sample notification title", "sample body", fcmRadioOption, type: NotificationType.call
                    ),
                    details: Person("sample", "sample@mail.com", fcmToken: fcmRadioOption)
                  );
                },
                child: Text("Send FCM notification")
              ),
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
                          leading: Icon([Icons.dataset][index]),
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