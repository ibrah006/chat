


import 'package:chat/components/bubbles/callBubble.dart';
import 'package:chat/components/bubbles/messageBubble.dart';
import 'package:chat/components/static/concepts.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/services/provider/state_controller/state_controller.dart';
import 'package:chat/users/person.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends MainWrapperStateful {

  late Person person;

  final TextEditingController messageController = TextEditingController();

  // @deprecated
  // final List<Message> messages = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //
  final MessagesController messagesController = Get.put(MessagesController());

  final FriendsController friendsController = Get.put(FriendsController());

  @override
  Widget build(BuildContext context) {

    return true? ChatConcept() : Scaffold(
      appBar: AppBar(
        title: Text('${person.displayName?? "N/A display name"}${_auth.currentUser!.uid == person.uid? " (You)" : ""}'),
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: startCall,
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Obx(
          () {
        
            final messages = messagesController.data;
        
            return Column(
              children: [
                ...List.generate(
                  messages.length, (index) {
                    final Message message = messages[index];
            
                    print("is message a call: ${message.details.type}");
        
                    // TODO: fix this. this may be a tempoorary solution only.
                    if (
                      message.fromUserUid == person.uid && person.uid !=_auth.currentUser!.uid ||
                        (message.fromUserUid == _auth.currentUser!.uid && message.details.uid == person.uid)) {
                      return message.details.type == NotificationType.message? MessageBubble(message) : CallBubble(callDetails: message.details); 
                    }

                    return SizedBox();
                  }),
              ]
            );
          }
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(child: TextField(controller: messageController, decoration: InputDecoration(hintText: " Type your message..."),)),
          ElevatedButton(
            onPressed: sendFCMMessage,
            child: const Text("Send") 
          )
        ],
      ),
    );
  }

  Future<void> sendFCMMessage() async {

    final Message message = Message(
      Uuid().v1(),
      messageController.text,
      CallDetails.fromUserInfo(Person.fromFirebaseAuth(_auth), null),
      fromUserUid: _auth.currentUser!.uid);

    final notiTitle = _auth.currentUser!.displayName!;
    final notiBody = message.text;

    if (person.uid != _auth.currentUser!.uid) {
      // can't pass in message.details.fcmToken instead of person.fcmToken as the former holds the value(fcm token) of the current user in all scenarios
      await SendPushNotification().sendNotification(
        info: NotificationInfo(
          notiTitle, notiBody, person.fcmToken, type: NotificationType.message
        ),
        message: message
      );
    } else {
      // still make sure the data is saved to the local database
    }

    message.details = CallDetails.fromUserInfo(person, null);
    // message that was just sent is obv read by the current user
    message.isRead = true;
    setState(() {
      messagesController.data.add(message);
    });

    friendsController.updateLastMessage(message);
  }

  void startCall() async {
    /// NOTE ///
    /// the below datetime will differ from the one that is created in the below message object. (insignificantly vary).
    final DateTime datetime = DateTime.now();
    final CallDetails callDetails = CallDetails.fromUserInfo(person, CallType.video, isCaller_: true, timestamp: datetime, state_: CallState.ongoing);
    final message = Message.call(callDetails, fromUserUid_: _auth.currentUser!.uid);

    setState(() {
      messagesController.data.add(message);

    });

    await Get.toNamed(
      "/call",
      arguments: message.toMap()
    );

    message.details.state = CallState.ended;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    person = Get.arguments;
  }

}