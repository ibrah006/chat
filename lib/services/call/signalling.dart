


import 'dart:convert';

import 'package:chat/constants/basic_bloc.dart';
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/call/call_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {

  late final String roomOwner; 

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;

  final BasicBloc<CallState> callStateHandler = BasicBloc<CallState>();

  bool isRemoteUserConnected = false;

  Future<void> _initVideoToRemote({required FirebaseFirestore db, required DocumentReference roomRef}) async {

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    roomId = roomRef.id;
    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
  }

  Future<String> createRoom(RTCVideoRenderer remoteRenderer, CallType initialCallType, {required String friend}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection(friend).doc();

    roomOwner = friend;

    print('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);

    // ROOM ID SET FROM HERE 👇👇
    await _initVideoToRemote(db: db, roomRef: roomRef);

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {

      final updatedRoom = snapshot.data();
      print('Got updated room: $updatedRoom');

      if (updatedRoom==null) {
        // remote user disconnected/hungup
        return;
      }

      Map<String, dynamic> data = updatedRoom as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {

        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);

        callStateHandler.sink.add(CallState.talking);
      }
    });
    // Listening for remote session description above

    // print("peerConnection configuration ${peerConnection!.getConfiguration}");

    // roomRef.set({
    //   "call": initialCallType.name, 
    // });

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
    // Listen for remote ICE candidates above

    return roomId!;
  }

  Future<void> joinRoom(String joinRoomId, RTCVideoRenderer remoteVideo, {required String currentuser}) async {

    roomOwner = currentuser;

    roomId = joinRoomId;
    FirebaseFirestore db = FirebaseFirestore.instance;

    print("join room id: $roomId");
    DocumentReference roomRef = db.collection(currentuser).doc('$roomId'); 
    var roomSnapshot = await roomRef.get();
    print('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data, roomSnapshot alternative data check: ${roomSnapshot.reference.get()}');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': false});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp(RTCVideoRenderer localVideo, {required String caller}) async {
    _startCallEnd(localVideo);

    print("roomId on ending call: $roomId");
    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection(caller).doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      calleeCandidates.docs.forEach((document) => document.reference.delete());

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      callerCandidates.docs.forEach((document) => document.reference.delete());

      await roomRef.delete();
    }

    _disposeLocalAndRemoteStreams();

    roomId = null;
  }

  void hostUserOnEnd(RTCVideoRenderer localVideo) {
    _startCallEnd(localVideo);

    _disposeLocalAndRemoteStreams();
  }

  _startCallEnd(RTCVideoRenderer localVideo) {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();
  }

  _disposeLocalAndRemoteStreams() {
    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        print('Remote user connected');
        isRemoteUserConnected = true;
        callStateHandler.sink.add(CallState.talking);
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        print('Remote user disconnected');
        isRemoteUserConnected = false;
        callStateHandler.sink.add(CallState.ended);
      }
    };

    /// TODO: see below 👇
    /// These might need further testing before implementing
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
        
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        print('Remote user connected');
        isRemoteUserConnected = true;

        callStateHandler.sink.add(CallState.talking);
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
                state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                state == RTCIceConnectionState.RTCIceConnectionStateClosed) {

        print('Remote user disconnected or call ended');
        isRemoteUserConnected = false;

      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) async {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}