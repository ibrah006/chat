
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/services/notification/send_notification.dart';
import 'package:chat/users/person.dart';

enum CallType {
  video, audio
}

class CallDetails extends Person implements NotificationInfo {
  CallDetails(String uid, String email, this.fcmToken, {required this.callType, required displayName}) : super(uid, email, displayName: displayName, fcmToken: fcmToken);

  final CallType callType;

  static CallDetails fromUserInfo(Person userInfo, CallType callType_, {bool? isCaller_}) {
    return CallDetails(userInfo.uid!, userInfo.email!, userInfo.fcmToken, callType: callType_, displayName: userInfo.displayName);
  }

  @override
  Map<String, dynamic> toMap() {
    return  {
      "uid": uid,
      "email": email,
      "fcmToken": fcmToken,
      "callType": callType.name,
      "displayName": displayName
    };
  }

  static CallDetails fromMap(Map map) {
    final callTypes = CallType.values.map((e)=> e.name).toList();


    return CallDetails(
      map["uid"],
      map["email"],
      map["fcmToken"]?? map["token"],
      callType: CallType.values[callTypes.indexOf(map["callType"])],
      displayName: map["displayName"],
    );
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