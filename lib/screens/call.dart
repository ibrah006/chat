import 'package:chat/main.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/call/signalling.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/widget_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends MainWrapperStateful {

  CallScreen();

  ///

  late bool initInProgress;
  String? roomId;

  final TextEditingController roomController = TextEditingController();

  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // StreamSubscription? callListener;

  late final CallDetails callDetails;

  bool? isCaller;

  @override
  void dispose() {
    super.dispose();

    disposeSignal();
  }
  
  
  @override
  void initState() {

    callDetails = CallDetails.fromMap(Get.arguments);

    print("call detials: ${callDetails.toString()}");

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
  }

  /// delayed is important property. should be true when received call end state is received from StreamBuilder
  void hangUp({bool delayed = false}) async {
    if (delayed) await Future.delayed(Duration(seconds: 4));

    // setting the document fields like this will overwrite the exisintg fields. MEANING THE 'offer' WILL BE GONE. Which is ok because the call is no longer needed.
    FirebaseFirestore.instance.collection(ROOMOWNER).doc(roomId).set({
      "isCallerEnded": true
    });

    disposeSignal().then((value) {
      Navigator.pop(context);
    });
  }

  disposeSignal() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();

    if (!isCaller!) {
      try {
        signaling.hangUp(_localRenderer, caller: ROOMOWNER);
      } catch(e) {
        print("not in call to hand up");
      }
    } else {
      signaling.hostUserOnEnd(_localRenderer);
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


  @override
  Widget build(BuildContext context) {

    // super.buildinit(context);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<CallState>(
          initialData: CallState.incoming,
          stream: signaling.callEndStateHandler.stream,
          builder: (context, AsyncSnapshot<CallState> snapshot) {

            if (snapshot.data == CallState.ended) {
              hangUp(delayed: true);
              return const Center(child: Text("Call ended"));
            }

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
                              case 0: autoManageCallState();
                              case 1: autoManageCallState();
                              case 2: hangUp();
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
        ),
      )
    );
  }

  Future<void> sendFCMMessage() async {

    callDetails.initializeRoomId(roomId!);

    // print("currentUserToken: $currentDeviceFCMToken \n toUserToken: $messageToToken");

    final notiTitle = callDetails.displayName!;
    final notiBody = "Invites you to a ${callDetails.callType == CallType.audio? "Audio" : "Video"} call";

    print("roomId from calldetails: ${callDetails.roomId}");

    await SendPushNotification().sendNotification(
      info: NotificationInfo(
        notiTitle, notiBody, callDetails.fcmToken, type: NotificationType.call
      ),
      details: callDetails
    );
  }


  Future<void> autoManageCallState() async {

    // below line decides if the user is caller or callee
    isCaller = callDetails.roomId == null;

    if (isCaller!) {
      roomId = await signaling.createRoom(_remoteRenderer, CALLTYPE, friend: ROOMOWNER);
        // await signaling.createRoom(_remoteRenderer);
      roomController.text = roomId!;

      await Clipboard.setData(ClipboardData(text: roomId!));

      initInProgress = false;

      sendFCMMessage();
    } else {

      signaling.callEndStateHandler.sink.add(CallState.talking);

      await signaling.joinRoom(
        callDetails.roomId!,
        _remoteRenderer,
        currentuser: ROOMOWNER
      );

      FirebaseFirestore.instance.collection(ROOMOWNER).doc(signaling.roomId).snapshots().listen((docSnapshot) {
        final isEndedByCaller = docSnapshot.get("isCallerEnded");
        if (isEndedByCaller == true) {
          signaling.callEndStateHandler.sink.add(CallState.ended);
          return;
        }
      });
    }
    
    setState(() {});
  }
}
