
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/users/person.dart';

class Message {
  Message(this.text,
    this.person, {
    final DateTime? timestamp,
    this.notificationType = NotificationType.message
  }) {
    datetime = timestamp?? DateTime.now();
  }

  bool get _isMessage => notificationType == NotificationType.message;

  final String text;
  /// this is auto unless specified
  late final DateTime datetime;
  final Person person;

  late final NotificationType notificationType;


  /// change the parameter if video call
  static Message call(Person person_, {NotificationType type = NotificationType.call}) {
    if (type == NotificationType.message) throw "Notification type cannot be .message when calling";

    return Message("Video call", person_);
  }
}