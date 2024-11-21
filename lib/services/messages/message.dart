
import 'dart:io';

import 'package:chat/services/call/call_details.dart';
import 'package:chat/services/notification/notification_type.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Message {
  Message(
    this.id,
    this.text,
    this.details,
    {
    final DateTime? timestamp,
    this.notificationType = NotificationType.message,
    required this.fromUserUid,
    this.isRead = true,
    this.isSending = false
  }) {
    datetime = timestamp?? DateTime.now();
  }

  bool isSending;

  @deprecated
  bool get _isMessage => notificationType == NotificationType.message;

  final String text, id;
  /// this is auto unless specified
  late final DateTime datetime;
  // Can be of the instance CallDetails or Person itself
  CallDetails details;

  late final NotificationType notificationType;

  final String fromUserUid;

  bool get isSender => fromUserUid == FirebaseAuth.instance.currentUser!.uid;

  bool isRead;

  @deprecated
  CallDetails? callDetails;

  Message clnoeWith({CallDetails? details}) {
    final copy = Message.fromMap(Map.of(toMap()));
    if (details!=null) copy.details = details;
    print("data from clnoeWith - after: ${copy.toMap()}");
    return copy;
  }

  /// change the parameter if video call
  static Message call(CallDetails callDetails_, {required String fromUserUid_}) {
    if (callDetails_.type == NotificationType.message) throw "Notification type cannot be .message when calling";

    final messageId = Uuid().v1();
    final message = Message(messageId, "Video call", callDetails_, fromUserUid: fromUserUid_);

    return message;
  }

  AudioMessage? isAudio() {
    final rawData = toMap();

    return notificationType == NotificationType.voiceMessage? toAudioMessage(rawData["downloadUrl"], rawData["path"], rawData["duration"], isSending_: rawData["isSending"]) : null;
  }

  Map<String, dynamic> toMap() {
    return {
      ...details.toMap(),
      "id": id,
      "message": text,
      "datetime": datetime.millisecondsSinceEpoch.toString(),
      "notificationType": notificationType.name,
      "fromUser": fromUserUid,
      "isSending": isSending.toString()
    };
  }

  // look for possible bugs as the the folowing function may not have inherited all the property values from message. there's a simple fix for this
  AudioMessage toAudioMessage(String? downloadUrl, String? path, String durationInSeconds, {required String isSending_}) {    
    print("duration in seconds converted from toAudioMessage func: ${durationInSeconds}");
    return AudioMessage(id, details, fromUserUid: fromUserUid, downloadUrl: downloadUrl, path: path, duration: Duration(seconds: int.parse(durationInSeconds)), isSending: bool.parse(isSending_));
  }

  static Message fromMap(Map<String, dynamic> map, {bool onReceive = false}) {
    final notificationTypes = NotificationType.values.map((e)=> e.name).toList();

    var message = Message(
      map["id"]?? map["messageId"],
      map["message"]?? map["text"],
      CallDetails.fromMap(map),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map["datetime"] is String? int.parse(map["datetime"]) : map["datetime"]),
      notificationType: NotificationType.values[notificationTypes.indexOf(map["notificationType"])],
      fromUserUid: map["fromUser"]?? map["fromUserUid"],
      isSending: onReceive? false : (bool.parse(map["isSending"]?? "false"))
    );

    print("debug info from Message.fromMap- duration: ${map["duration"]}, ${message.notificationType}");

    // Is an Audio Message
    if (message.notificationType == NotificationType.voiceMessage) {
      
      final String? path = onReceive? null : map["path"];

      final audioMessage = message.toAudioMessage(map["downloadUrl"], path, map["duration"], isSending_: (!onReceive).toString());

      // if on receive is checked then the audio is downloaded and the new path inside of the AudioMessage instance will be set to a non-null value if successfully found and downloaded file
      // if (onReceive) {
      //   audioMessage.download();
      // }

      message = audioMessage;
    }

    return message;
  }
}

class AudioMessage extends Message {
  AudioMessage(
    String id, CallDetails details, {required fromUserUid, required this.downloadUrl, String? path, required this.duration, bool isSending = false}
    ) : super(id, "Sent a voice message", details, notificationType: NotificationType.voiceMessage, fromUserUid: fromUserUid, isSending: isSending) {

    if (path != null) this.path = path;
    // if (duration != null) this.duration = duration;
  }

  String? downloadUrl;

  late final String path;
  final Duration duration;

  // Function to download the file from the backend
  Future<void> download() async {

    final filename = "audio_$id.aac";

    // Request storage permission (on Android)
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (!permissionStatus.isGranted) {
      print('Storage permission denied');
      return;
    }

    // Backend URL - Replace with your backend's IP address or domain
    final url = Uri.parse('http://192.168.0.103:5000/download/$filename'); // Use your local IP or server URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Get the app's document directory to store the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      // Write the response body (file) to the local file
      await file.writeAsBytes(response.bodyBytes);

      path = filePath;

      print('File downloaded to $filePath');
    } else {
      print('Failed to download file');
    }
  }

  @override
  Map<String, dynamic> toMap() {

    getPath() {
      try {
        return path;
      } catch(e) {
        return "downloading";
      }
    }

    return {
      ...super.toMap(),
      "downloadUrl": downloadUrl,
      "path": getPath(),
      "duration": duration.inSeconds.toString()
    };
  }

}