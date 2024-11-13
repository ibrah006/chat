


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
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, left: 10),
          child: CircleAvatar(
            backgroundColor: Color(0xFF7233f5).withOpacity(.2),
            child: Icon(Icons.person_rounded) // replace with actual image
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${person.displayName?? "N/A display name"}${_auth.currentUser!.uid == person.uid? " (You)" : ""}'),
            Text('Online', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.phone),
            color: Color(0xFF7233f5)
          ),
          SizedBox(width: 20),
          IconButton(
            onPressed: startCall,
            icon: Icon(Icons.videocam),
            color: Color(0xFF7233f5)
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
            Obx(
              () {
                final messages = messagesController.data;

                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    ...List.generate(
                      messages.length, (index) {
                      final Message message = messages[index];
                          
                      print("is message a call: ${message.details.type}");

                      final time = DateFormat("hh:mm a").format(message.datetime);
                      
                      // TODO: fix this. this may be a tempoorary solution only.
                      if (
                        message.fromUserUid == person.uid && person.uid !=_auth.currentUser!.uid ||
                          (message.fromUserUid == _auth.currentUser!.uid && message.details.uid == person.uid)) {
                        return message.details.type == NotificationType.message?
                          message.isSender? _buildSentMessage(message.text, time) : _buildReceivedMessage(message.text, time)
                          : CallBubble(
                            isMissed: message.details.state! == CallState.missed,
                            callType: message.details.callType!.name.capitalizeFirst!,
                            callTime: DateFormat("hh:mm a").format(message.datetime),
                            duration: (message.details.duration!=null? (message.details.duration!.inSeconds > 0? "${message.details.duration!.inSeconds} minutes" : "${message.details.duration!.inMinutes} seconds") : "N/A").toString(),
                          ); 
                      }
                
                      return SizedBox();
                    })
                  ],
                );
              }
            ),

          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFFf9f9f9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            SizedBox(height: 4),
            Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFF7233f5), // purple color for sent message
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: GoogleFonts.poppins(color: Colors.white)),
            SizedBox(height: 4),
            Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedImageMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://example.com/image.jpg', // replace with actual image
            width: 200,
          ),
          SizedBox(height: 4),
          Text(
            'https://www.figma.com/file/chatappsdesign...',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 248, 248, 247),
        borderRadius: BorderRadius.circular(35)
      ),
      child: Row(
        children: [
          Icon(Icons.camera_alt, color: Color(0xFF7233f5)),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey.shade400),
                hintText: 'Type Here...',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.image, color: Color(0xFF7233f5)),
          SizedBox(width: 8),
          IconButton(
            onPressed: sendFCMMessage,
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
              minimumSize: WidgetStatePropertyAll(Size.zero)
            ),
            icon: Icon(Icons.send, color: Color(0xFF7233f5))
          ),
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

    print("we are ion the init of chta screen");

    if (person.lastMessage?.isRead == false) {
      person.lastMessage?.isRead = true;
    }
  }

}