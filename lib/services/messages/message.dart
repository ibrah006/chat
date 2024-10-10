
import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/users/person.dart';
import 'package:uuid/uuid.dart';

class   Message {
  Message(
    this.id,
    this.text,
    this.person, {
    final DateTime? timestamp,
    this.notificationType = NotificationType.message,
    required this.fromUserUid
  }) {
    datetime = timestamp?? DateTime.now();
  }

  bool get _isMessage => notificationType == NotificationType.message;

  final String text, id;
  /// this is auto unless specified
  late final DateTime datetime;
  final Person person;

  late final NotificationType notificationType;

  final String fromUserUid;

  CallDetails? callDetails;

  /// change the parameter if video call
  static Message call(CallDetails callDetails_, {required String fromUserUid_}) {
    if (callDetails_.type == NotificationType.message) throw "Notification type cannot be .message when calling";

    final messageId = Uuid().v1();
    final message = Message(messageId, "Video call", callDetails_, fromUserUid: fromUserUid_);

    message.callDetails = callDetails_;

    return message;
  }
}