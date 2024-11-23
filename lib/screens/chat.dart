


import 'package:chat/components/bubbles/bubble.dart';
import 'package:chat/components/bubbles/callBubble.dart';
import 'package:chat/components/static/message_input/add_expandable.dart';
import 'package:chat/components/static/voice_note_recorder.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/services/messages/voice_message.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/services/provider/provider_managers.dart';
import 'package:chat/services/provider/state_controller/state_controller.dart';
import 'package:chat/users/person.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  bool canVoice = true;
  @Deprecated("This is replaced by [RecordingState]")
  bool isRecordingVoice = false;

  bool isRecordingStateNone() {
    return voiceMessage.recordingState == RecordingState.none;
  }

  bool isRecording() {
    return voiceMessage.recordingState == RecordingState.recording;
  }

  bool isRecordingPaused() {
    return voiceMessage.recordingState == RecordingState.paused;
  }

  @override
  Widget build(BuildContext context) {

    print(voiceMessage.recordingState);

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

    final isSender = message.isSender;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Bubble(message),
    );
  }

  Widget _buildMessageInput() {
    return StreamBuilder(
      stream: voiceMessage.stateManager.stream,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,  // Background color of message input area set to white
          child: Row(
            children: [
              if (isRecordingStateNone()) AddExpandableButtons(),
              Expanded(
                child: !isRecordingStateNone()? VoiceNoteRecorder(
                  voiceMessage,
                  onPauseStopRecording: onPauseVoiceNote,
                  recordingState: voiceMessage.recordingState,
                  ) : Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],  // Text field container color set to light grey
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) {
                      if (value.trim().isEmpty && !canVoice) {
                        setState(() {
                          canVoice = true;
                        });
                      } else if (value.trim().isNotEmpty && canVoice) {
                        setState(() {
                          canVoice = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              // if (!isRecordingVoice) IconButton(
              //   icon: Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
              //   onPressed: () {},
              // ),
              IconButton(
                icon: Icon(!canVoice || !isRecordingStateNone()? Icons.send : Icons.mic_rounded , color: Color(0xFF6C63FF)),
                onPressed: !canVoice || !isRecordingStateNone()? sendFCMMessage : recordVoice,
              ),
            ],
          ),
        );
      }
    );
  }

  final VoiceMessage voiceMessage = VoiceMessage();

  void recordVoice() async {
    await voiceMessage.start();

    setState(() {
      // isRecordingVoice = true;
      voiceMessage.recordingState = RecordingState.recording;
    });
  }

  void onPauseVoiceNote() async {
    setState(() {
      voiceMessage.recordingState = RecordingState.paused;
    });

    await voiceMessage.pause();
  }

  void onStopVoiceNote() async {
    setState(() {
      // isRecordingVoice = false;
      voiceMessage.recordingState = RecordingState.none;
    });

    await voiceMessage.stop();
  }
  

  Future<void> _sendNoti(final Message messageOriginal) async {

    final notiTitle = messageOriginal.details.displayName!;
    final notiBody = messageOriginal.text;

    final message = Message.fromMap(messageOriginal.toMap());//messageOriginal.clnoeWith(details: CallDetails.fromUserInfo(Person.fromFirebaseAuth(_auth), null), map: messageOriginal.toMap());
    message.details =  CallDetails.fromUserInfo(Person.fromFirebaseAuth(_auth), null);

    print("message data from _sendNoti: ${message.toMap()}");

    print("person uid: ${person.uid}, curretn user uid: ${_auth.currentUser!.uid}");

    if (person.uid != _auth.currentUser!.uid) {
      // can't pass in message.details.fcmToken instead of person.fcmToken as the former holds the value(fcm token) of the current user in all scenarios
      try {
        await SendPushNotification().sendNotification(
          info: NotificationInfo(
            notiTitle, notiBody, person.fcmToken, type: NotificationType.message, email: person.email
          ),
          message: message
        );
      } catch(e) {
        print(e);

        // TODO manually set up and caught error. HANDLE THIS
      }
    } else {
      // still make sure the data is saved to the local database
    }
  }

  Future<void> sendFCMMessage() async {

    late final Message message;

    if (!isRecordingStateNone()) {
      onStopVoiceNote();
      // final path = voiceMessage.recordingPath;

      print("voice note path: ${voiceMessage.recordingPath}");

      final messageId = voiceMessage.getMessageId();

      print("this is the voice message id: $messageId");

      message = AudioMessage(
          messageId,
          CallDetails.fromUserInfo(person, null),
          fromUserUid: _auth.currentUser!.uid,
          downloadUrl: null,
          path: voiceMessage.recordingPath!,
          duration: voiceMessage.getDuration(),
          isSending: true);

      voiceMessage.send().then((value) async {
        await _sendNoti(message).then((value) {
          print("notification(message) sent successfully");
          // this setss the message isSending status = false which will be used in the ui to show whether or the message is sending or is sent.
          // messagesController.updateMessageSendingStatus(messageId);
          message.isSending = false;
          setState(() {});
        });
      });

    } else {
      
      // make sure text field is not empty before proceeding
      if (messageController.text.trim().isEmpty) {
        return;
      }

      message = Message(
        Uuid().v1(),
        messageController.text,
        CallDetails.fromUserInfo(person, null),
        fromUserUid: _auth.currentUser!.uid,
        isSending: true);     

      _sendNoti(message).then((value) {
        message.isSending = false;
        setState(() {});
      });
    }
    // message that was just sent is obv read by the current user
    message.isRead = true;
    setState(() {
      messagesController.data.add(message);
    });

    friendsController.updateLastMessage(message);

    // much needed to udpate the state
    setState(() {
      messageController.clear();
      canVoice = true;
    });
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

    Permission.storage.request().then((granted){
      print("is Storage permission granted: $granted");
    });

    voiceMessage.init();

    person = Get.arguments;

    print("we are ion the init of chta screen");

    if (_auth.currentUser!.uid != person.uid) {
      SendPushNotification.getUpdatedFcmToken(person.uid, person.email).then((String? newFcmToken) {
        if (newFcmToken != null) {
          // set the fcm token for user locally
          friendsController.updateFcmToken(email: person.email, updatedFcmToken: newFcmToken);
        }
      });
    }

    if (person.lastMessage?.isRead == false) {
      person.lastMessage?.isRead = true;
    }
  }

  @override
  void dispose() {
    voiceMessage.dispose();
    super.dispose();
  }
}