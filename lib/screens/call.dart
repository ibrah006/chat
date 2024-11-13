
import 'dart:async';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat/components/call/call_options_widget.dart';
import 'package:chat/main.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_options.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/call/signalling.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/users/person.dart';
import 'package:chat/widget_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat/constants/date.dart';

class CallScreen extends MainWrapperStateful {

  CallScreen();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///

  late bool initInProgress;
  String? roomId;

  final TextEditingController roomController = TextEditingController();

  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // StreamSubscription? callListener;

  late final Message callMessage;

  late final bool isCaller;

  late String roomOwner;
  
  final CallOptions callOptions = CallOptions();

  // will only be null once (initially)
  Stream? callTimeStream;
  Stopwatch callTime = Stopwatch();

  @override
  void dispose() {
    super.dispose();

    disposeSignal();
  }
  
  
  @override
  void initState() {

    // get call details passed in as arguments
    callMessage = Message.fromMap(Get.arguments);

    // below line decides if the user is caller or callee
    isCaller = callMessage.details.roomId == null;

    // TODO: there might be error here if this build is called before the actual build
    signaling.callStateHandler.sink.add(isCaller? CallState.ongoing : CallState.incoming);

    roomOwner = (isCaller? callMessage.details.uid : _auth.currentUser!.uid)!;

    // if callee then check if the room stil exists then proceed with the call init
    if (!isCaller) {
      FirebaseFirestore.instance.collection(roomOwner).doc(callMessage.details.roomId).get().then((roomData) {
        if (roomData.exists) {
          init();
        } else {
          // TODO: show some feedback that the room no longer exists
          Navigator.pop(context);
        }
      });
    } else {
      init();
    }

    
  }

  void init() {

    print("call detials: ${callMessage.details.toString()}");

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      print("remote rendeer srcobject id: ${stream.id}, ${stream.active}");
      setState(() {});
    });

    _localRenderer.initialize();
    _remoteRenderer.initialize();
    initializeCall().then((value) {

      // TODO: decide to turn on camera depending on call type
      // cameraOn = true;
    });

    signaling.callStateHandler.stream.listen((currentCallState) {
      if (currentCallState  == CallState.talking && callTimeStream == null) {
        callTime.start();
        callTimeStream = Stream.periodic(Duration(seconds: 1), (_time) {
          return _time;
        });
      }
    });
  }

  /// delayed is important property. should be true when received call end state is received from StreamBuilder
  

  disposeSignal() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();

    try {
      signaling.hangUp(_localRenderer, caller: roomOwner);   
    } catch(e) {
      print("not in call to hand up");
    }
  }

  Future<void> initCamera() async {
    await Permission.camera.request();

    await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    setState(() {
    });
  }

  Future<void> initializeCall() async {

    await [Permission.microphone, Permission.camera].request();

    // callListener?.cancel();
    initInProgress = true;

    // TODO: initialize camera only if it's a video calls
    // if (widget.initialCallType==CallType.video) await initCamera();
    await initCamera();

    // TODO: fix this function and uncomment
    autoManageCallState();
  }

  Future? timeSinceScreenTap;
  bool showCallOptions = false;

  void startTimeSinceScreenTap(CallState callState) async {

    showCallOptions = true;
    setState(() {});

    timeSinceScreenTap = Future.delayed(Duration(seconds: 5));
    
    timeSinceScreenTap!.then((value) {
      showCallOptions = false;
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {

    // super.buildinit(context);
    return Scaffold(
      body: StreamBuilder<CallState>(
        stream: signaling.callStateHandler.stream,
        builder: (context, AsyncSnapshot<CallState> snapshot) {

          final CallState currentCallState = snapshot.data?? CallState.initing;
      
          if (snapshot.data == CallState.ended) {
            callOptions.hangUp(disposeSignal, context, delayed: true);
            return const Center(child: Text("Call ended"));
          }

          print("currentCallState: $currentCallState");
      
          return GestureDetector(
            onTap: ()=> startTimeSinceScreenTap(currentCallState),
            child: Stack(
              children: [
                currentCallState == CallState.talking? RTCVideoView(_remoteRenderer) : SizedBox(),
                SizedBox(
                  height: currentCallState == CallState.talking? MediaQuery.of(context).size.height/3.7 : null,
                  width: currentCallState == CallState.talking? MediaQuery.of(context).size.width/3.7 : null,
                  child: RTCVideoView(_localRenderer),
                ),
                StreamBuilder(
                  stream: callOptions.stateUpdater.stream,
                  builder: (context, snapshot) {
                    return !showCallOptions? SizedBox() : Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSize(
                        duration: Duration(milliseconds: 350),
                        child: Container(
                          height: showCallOptions? null : 0,
                          child: CallOptionsWidget(
                            isSpeakerOn: callOptions.isSpeakerOn,
                            isMicOn: callOptions.isMicOn,
                            isCameraOn: callOptions.isCameraOn,
                            onSpeakerToggle: callOptions.toggleSpeaker,
                            onMicToggle: callOptions.toggleMic,
                            onCameraToggle: callOptions.toggleCamera,
                            onEnd: ()=> callOptions.hangUp(disposeSignal, context)
                          ),
                        ),
                      )
                    );
                  }
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSize(
                    duration: Duration(milliseconds: 350),
                    child: Container(
                      height: showCallOptions? null : 0,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            color: Colors.white.withOpacity(0.25),
                            padding: EdgeInsets.only(top: 10, bottom: 17),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 16.0),
                                Text(
                                  callMessage.details.displayName!,
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.0), // Slight spacing between name and status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(currentCallState == CallState.talking? Icons.phone_in_talk_rounded : Icons.call_made, color: Colors.grey),
                                    SizedBox(width: 10),
                                    currentCallState != CallState.talking? Row(
                                      children: [
                                        Text(
                                          currentCallState == CallState.ongoing? "Outgoing" : "Waiting",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: AnimatedTextKit(
                                            repeatForever: true,
                                            animatedTexts: [
                                              TyperAnimatedText('...', speed: Duration(milliseconds: 180), textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey), curve: Curves.slowMiddle)
                                            ],
                                          ),
                                        )
                                      ],
                                    ) : StreamBuilder(
                                      stream: callTimeStream,
                                      builder: (context, snapshot) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 13),
                                          child: Text(DateManager.formatDuration(snapshot.data)),
                                        );
                                      }
                                    )
                                  ],
                                ),
                              ],
                            )
                          ),
                        ),
                      ),
                    ),
                  )
                )
              ],
            ),
          );
      
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    4,
                    (index) {
                      return ElevatedButton(
                        onPressed: () {
                          switch(index) {
                            // case 0: autoManageCallState();
                            // case 1: autoManageCallState();
                            case 2: callOptions.hangUp(disposeSignal, context);;
                            // case 3: sendFCMMessage();
                          }
                        },
                        style: index==2? const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red)
                        ) : null,
                        child: Text(["join room", "create room", "end call", "Send notification"][index])
                      );
                    }
                  )
                ),
              ),
              ListTile(
                leading: Container(
                  color: Colors.yellow,
                  height: 20,
                  width: 20,
                ),
                trailing: Text("current user"),
              ),
          
              Row(
                children: List.generate(
                  2, (index) {
                    return Expanded(
                      child: SizedBox(
                          height: 300,
                          child: Container(
                              decoration: BoxDecoration(
                                border: index==0? Border.all(
                                  color: Colors.yellow,
                                  width: 4
                                ) : null
                              ),
                              child: RTCVideoView([_localRenderer, _remoteRenderer][index])
                          )
                      ),
                    );
                  }
                )
              ),
          
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller: roomController,
                    )),
                    ElevatedButton.icon(
                      onPressed: () {
                        //copy room id
                      },
                      label: Text("Copy"),
                      icon: Icon(Icons.copy),
                    )
                  ],
                ),
              )
            ],
          );
        }
      )
    );
  }

  Future<void> sendFCMMessage() async {

    callMessage.details.initializeRoomId(roomId!);

    // print("currentUserToken: $currentDeviceFCMToken \n toUserToken: $messageToToken");

    final copyOfCallDetailsForCurrentUser = callMessage.details.copyFrom(Person.fromFirebaseAuth(_auth));

    final notiTitle = copyOfCallDetailsForCurrentUser.displayName!;
    final notiBody = "Invites you to a ${copyOfCallDetailsForCurrentUser.callType == CallType.audio? "Audio" : "Video"} call";

    print("callMessage: ${callMessage.toMap().toString()}");

    await SendPushNotification().sendNotification(
      info: NotificationInfo(
        notiTitle, notiBody, callMessage.details.fcmToken, type: NotificationType.call
      ),
      message: callMessage.clnoeWith(details: copyOfCallDetailsForCurrentUser)
    );
  }


  Future<void> autoManageCallState() async {

    if (isCaller) {
      roomId = await signaling.createRoom(_remoteRenderer, CALLTYPE, friend: roomOwner);
        // await signaling.createRoom(_remoteRenderer);
      roomController.text = roomId!;

      await Clipboard.setData(ClipboardData(text: roomId!));

      initInProgress = false;

      sendFCMMessage();
    } else {

      signaling.callStateHandler.sink.add(CallState.talking);

      await signaling.joinRoom(
        callMessage.details.roomId!,
        _remoteRenderer,
        currentuser: roomOwner
      );
    }
    
    setState(() {});
  }
}
