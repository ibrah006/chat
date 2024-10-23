
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class Message {
  Message(
    this.id,
    this.text,
    this.details, {
    final DateTime? timestamp,
    this.notificationType = NotificationType.message,
    required this.fromUserUid
  }) {
    datetime = timestamp?? DateTime.now();
  }

  @deprecated
  bool get _isMessage => notificationType == NotificationType.message;

  final String text, id;
  /// this is auto unless specified
  late final DateTime datetime;
  // Can be of the instance CallDetails or Person itself
  final CallDetails details;

  late final NotificationType notificationType;

  final String fromUserUid;

  bool get isSender => fromUserUid == FirebaseAuth.instance.currentUser!.uid;

  @deprecated
  CallDetails? callDetails;

  /// change the parameter if video call
  static Message call(CallDetails callDetails_, {required String fromUserUid_}) {
    if (callDetails_.type == NotificationType.message) throw "Notification type cannot be .message when calling";

    final messageId = Uuid().v1();
    final message = Message(messageId, "Video call", callDetails_, fromUserUid: fromUserUid_);

    return message;
  }

  Map<String, dynamic> toMap() {
    return {
      ...details.toMap(),
      "id": id,
      "message": text,
      "datetime": datetime.millisecondsSinceEpoch.toString(),
      "notificationType": notificationType.name,
      "fromUser": fromUserUid
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    final notificationTypes = NotificationType.values.map((e)=> e.name).toList();

    return Message(
      map["id"]?? map["messageId"],
      map["message"]?? map["text"],
      CallDetails.fromMap(map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map["datetime"] is String? int.parse(map["datetime"]) : map["datetime"]),
      notificationType: NotificationType.values[notificationTypes.indexOf(map["notificationType"])],
      fromUserUid: map["fromUser"]?? map["fromUserUid"]
    );
  }
}