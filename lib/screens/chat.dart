


import 'package:chat/components/bubbles/callBubble.dart';
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
import 'package:intl/intl.dart';
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

  var isOnline = false;

  bool get isYourself => person.uid == _auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,  // AppBar background color set to white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF6C63FF).withOpacity(.35),
              child: Icon(Icons.person, size: 27, color: Colors.black87)
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.displayName!,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: isYourself? null : null,
            icon: Icon(Icons.call_rounded)
          ),
          SizedBox(width: 6),
          IconButton(
            onPressed: isYourself? null : startCall,
            icon: Icon(Icons.videocam_rounded)
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                final messages = messagesController.data;

                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    ...List.generate(
                      messages.length, (index) {
                        final Message message = messages[index];

                        print("is message a call: ${message.details.type}");

                        print("call duration: ${message.details.duration}");

                        // TODO: fix this. this may be a tempoorary solution only.
                        if (
                          message.fromUserUid == person.uid && person.uid !=_auth.currentUser!.uid ||
                            (message.fromUserUid == _auth.currentUser!.uid && message.details.uid == person.uid)) {
                          return message.details.type == NotificationType.message?
                            _buildMessageBubble(message)
                            : CallBubble(
                              callMessage: message,
                              callState: message.details.state!,
                              callType: message.details.callType!.name.capitalizeFirst!,
                              callTime: DateFormat("hh:mm a").format(message.datetime),
                              duration: (message.details.duration!=null? (message.details.duration!.inSeconds > 0? "${message.details.duration!.inSeconds} seconds" : "${message.details.duration!.inMinutes} minutes") : "N/A").toString(),
                            ); 
                        }
                  
                        return SizedBox();
                      }
                    )
                  ]
                );
              }
            ),
          ),
          _buildMessageInput(),
        ],
      ),
      backgroundColor: Colors.grey[100],  // Background color set to light grey
    );
  }

  Widget _buildMessageBubble(Message message) {

    bool isLink = false;

    final time = DateFormat("hh:mm a").format(message.datetime);

    final isSender = message.isSender;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Color(0xFF6C63FF) : Colors.white70,  // Sent bubble: #6C63FF, Received bubble: light grey
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isSender ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isSender ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            isLink
                ? GestureDetector(
                    onTap: () {
                      // Open link
                    },
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.blue[200], decoration: TextDecoration.underline),
                    ),
                  )
                : Text(
                    message.text,
                    style: TextStyle(
                      color: isSender ? Colors.white : Colors.black87,
                    ),
                  ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(fontSize: 10, color: isSender ? Colors.white70 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,  // Background color of message input area set to white
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],  // Text field container color set to light grey
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF6C63FF)),
            onPressed: sendFCMMessage,
          ),
        ],
      ),
    );
  }

  Future<void> sendFCMMessage() async {

    if (messageController.text.trim().isEmpty) {
      return;
    }

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

    // message.details.state = CallState.ended;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    person = Get.arguments;

    print("we are ion the init of chta screen");

    if (person.lastMessage?.isRead == false) {
      person.lastMessage?.isRead = true;
    }
  }

}