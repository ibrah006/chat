
import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/users/person.dart';

enum CallType {
  video, audio
}

class CallDetails extends Person implements NotificationInfo {
  CallDetails(String uid, String email, this.fcmToken, {required this.callType, required displayName, this.state = CallState.ended, required DateTime? timestamp}) : super(uid, email, displayName: displayName, fcmToken: fcmToken) {
    datetime = timestamp?? DateTime.now();
  }

  // will be null for a text message
  final CallType? callType;

  String? roomId;

  // will be null for a text message
  CallState? state;

  late DateTime datetime;

  Duration? duration;

  static CallDetails fromUserInfo(Person userInfo, CallType? callType_, {bool? isCaller_, DateTime? timestamp, CallState? state_}) {
    return CallDetails(
      userInfo.uid!,
      userInfo.email!,
      userInfo.fcmToken,
      callType: callType_,
      displayName: userInfo.displayName,
      timestamp: timestamp,
      state: state_?? CallState.ended);
  }

  void initializeRoomId(String id) {
    roomId = id;
  }

  @override
  Map<String, dynamic> toMap() {
    return  {
      "uid": uid,
      "email": email,
      "fcmToken": fcmToken,
      "callType": callType?.name,
      "displayName": displayName,
      "roomId": roomId,
      "state": state?.name,
      "duration": duration
    };
  }

  CallDetails copyFrom(Person person, {CallState state_ = CallState.ongoing, DateTime? timestamp}) {
    final data = CallDetails(
      person.uid?? uid!,
      person.email?? email!,
      person.fcmToken,
      callType: callType,
      state: state_,
      displayName: person.displayName?? displayName,
      timestamp: timestamp);

    if (roomId != null) {
      data.initializeRoomId(roomId!);
    }

    data.debugErrorFromPast = person.debugErrorFromPast;

    return data;
  }

  static CallDetails fromMap(Map map) {
    final callTypes = CallType.values.map((e)=> e.name).toList();
    final callStates = CallState.values.map((e)=> e.name).toList();

    final instance = CallDetails(
      map["uid"],
      map["email"],
      map["fcmToken"]?? map["token"],
      callType: map["callType"]==null? null :  CallType.values[callTypes.indexOf(map["callType"])],
      state: map["state"] == null? null : (CallState.values[callStates.indexOf(map["state"])]?? CallState.ended),
      displayName: map["displayName"],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map["datetime"] is String? int.parse(map["datetime"]) : map["datetime"])
    );

    try {
      instance.initializeRoomId(map["roomId"]);
    } catch(e) {}

    return instance;
  }

  @override
  String toString() {
    return toMap().toString();
  }
  
  @override
  String get body => "Invites you to a ${callType?.name}";
  
  @override
  String get title => displayName?? email!;
  
  @override
  // TODO: implement type
  NotificationType get type {
    switch(callType) {
      case CallType.video: return NotificationType.videoCall;
      case CallType.audio: return NotificationType.call;
      default: return NotificationType.message;
    }
  }
  
  @override
  final String fcmToken;
}