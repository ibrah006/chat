import 'dart:convert';
import 'package:chat/constants/notifications_c.dart';
import 'package:chat/constants/serviceAccCred.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:chat/users/person.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';


class SendPushNotification {

  // Replace this with your actual project ID
  static const String projectId = 'flash-chat-72eca';

  // Get Access Token using the service account key
  Future<String> _getAccessToken(String deviceFcmToken) async {

    var credentials = ServiceAccountCredentials.fromJson(ServiceAccCred.secret);

    var scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    final client = http.Client();
    final authClient = await clientViaServiceAccount(credentials, scopes);

    var token = await authClient.credentials.accessToken;
    client.close();

    return token.data;
  }

  // Send notification using the FCM HTTP v1 API
  Future<void> sendNotification({required NotificationInfo info, required Person details}) async {
    String accessToken = await _getAccessToken(info.fcmToken!);

    var url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    Map<String, dynamic> body = NotificationConstants.getNotificationPayload(
      info, data: details.toMap()
    );

    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully: ${response.body}');
    } else {
      print('Failed to send notification: ${response.statusCode} ${response.body}');
    }
  }

}

class NotificationInfo {
  const NotificationInfo(this.title, this.body, this.fcmToken, {required this.type});

  final String? fcmToken;

  final String title, body;
  final NotificationType type;
}

