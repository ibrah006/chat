
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

  final CallType callType;

  String? roomId;

  CallState state;

  late DateTime datetime;

  static CallDetails fromUserInfo(Person userInfo, CallType callType_, {bool? isCaller_, DateTime? timestamp, CallState? state_}) {
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
      "callType": callType.name,
      "displayName": displayName,
      "roomId": roomId,
      "state": state.name
    };
  }

  CallDetails copyFrom(Person person, {CallState state_ = CallState.ongoing, DateTime? timestamp}) {
    return CallDetails(
      person.uid?? uid!,
      person.email?? email!,
      person.fcmToken,
      callType: callType,
      state: state_,
      displayName: person.displayName?? displayName,
      timestamp: timestamp)
        ..initializeRoomId(roomId!)
        ..debugErrorFromPast = person.debugErrorFromPast;
  }

  static CallDetails fromMap(Map map) {
    final callTypes = CallType.values.map((e)=> e.name).toList();

    final instance = CallDetails(
      map["uid"],
      map["email"],
      map["fcmToken"]?? map["token"],
      callType: CallType.values[callTypes.indexOf(map["callType"])],
      state: map["state"]?? CallState.ended,
      displayName: map["displayName"],
      timestamp: map["datetime"]
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
  String get body => "Invites you to a ${callType.name}";
  
  @override
  String get title => displayName?? email!;
  
  @override
  // TODO: implement type
  NotificationType get type {
    final List<String> notiTypes = NotificationType.values.toList().map((e)=> e.name).toList();
    final int notiTypeIndex = notiTypes.indexOf(callType.name);

    return NotificationType.values[notiTypeIndex];
  }
  
  @override
  final String fcmToken;
}