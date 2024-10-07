
import 'package:chat/services/notification/send_notification.dart';

class NotificationConstants {
  static Map<String, dynamic> getNotificationPayload(NotificationInfo details, {required Map data}) {
    return {
      "message": {
        "token": details.fcmToken,
        "notification": {
          "title": details.title,
          "body": details.body
        },
        "data": data
      },
    };
    return {
      "message": {
        "token": details.fcmToken,
        "notification": {
          "title": details.title,
          "body": details.body
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "action_1": "like",  
          "action_2": "reply",
        },
        "android": {
          "notification": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "body": details.body,
            "title": details.title
          },
        }
      }
    };
  }
}

