


import 'package:chat/components/bubbles/callBubble.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/users/person.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends MainWrapperStateful {

  late Person person;

  final TextEditingController messageController = TextEditingController();

  final List<Message> messages = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(person.displayName!),
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: startCall,
          )
        ]
      ),
      body: Column(
        children: List.generate(
          messages.length, (index) {
            final Message message = messages[index];
            return CallBubble(callDetails: message.details);
          }),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(child: TextField(controller: messageController, decoration: InputDecoration(hintText: " Type your message..."),)),
          const ElevatedButton(
            // onPressed: sendFCMMessage,
            onPressed: null,
            child: Text("Send") 
          )
        ],
      ),
    );
  }

  void startCall() async {
    /// NOTE ///
    /// the below datetime will differ from the one that is created in the below message object. (insignificantly vary).
    final DateTime datetime = DateTime.now();
    final CallDetails callDetails = CallDetails.fromUserInfo(person, CallType.video, isCaller_: true, timestamp: datetime, state_: CallState.ongoing);
    final message = Message.call(callDetails, fromUserUid_: _auth.currentUser!.uid);

    setState(() {
      messages.add(message);
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