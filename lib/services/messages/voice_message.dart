
import 'dart:async';
import 'dart:io';

import 'package:chat/constants/basic_bloc.dart';
import 'package:chat/constants/date.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

enum RecordingState {
  recording, none, paused
}

class VoiceMessage {

  late Timer timer;

  RecordingState recordingState = RecordingState.none;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;

  String? recordingPath;

  bool isPlaying = false;

  final BasicBloc stateManager = BasicBloc();

  Future<void> playPreview() async {
    if (recordingPath == null) return;

    isPlaying = true;
    updateState();

    await _player!.startPlayer(
      fromURI: recordingPath,
      whenFinished: () { 
        isPlaying = false;
        updateState();
      },  
    );
  }

  updateState() {
    stateManager.update();
  }

  Future<void> pausePreview() async {
    isPlaying = false;
    updateState();

    await _player!.pausePlayer();
  }

  Future<void> _stopPreview() async {
    isPlaying = false;
    updateState();

    try {
      await _player!.stopPlayer();
    } catch(e) {}
  }

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  Future<void> start() async {

    // Request permissions for microphone
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }
    
    final messageId = Uuid().v1();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/audio_$messageId.aac';

    recordingPath = filePath;

    _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
  }

  String getMessageId() {
    if (recordingPath == null) throw "There is no voice message intialized. FAILED TO GET MESSAGE ID. TIP: make sure to check if the recordingPath != null before running this function";

    return recordingPath!.split("/").last.split("_")[1].split(".")[0];
  }

  Future<void> cancel() async {
    if (recordingPath != null) {
      final file = File(recordingPath!);

      if (await file.exists()) {
        await file.delete();
        print("Recording deleted: $recordingPath");
        recordingPath = null;

        recordingState = RecordingState.none;
        _stopPreview();
      } 
    }
  }

  Future<void> pause() async {
    timer.cancel();
    await _recorder!.pauseRecorder();
  }

  Future<void> stop() async {
    timer.cancel();
    recordingPath = await _recorder!.stopRecorder();

    recordingState = RecordingState.none;
    updateState();

    // recorded file
    print("Recording saved at: $recordingPath");
  }

  int _getCallSeconds()=> (timer.tick * .2).toInt();

  Duration getDuration() {
    return Duration(seconds: _getCallSeconds());
  }

  String getDurationFormatted() {
    return DateManager.formatSecondsToMinutes(_getCallSeconds());
  }

  void dispose() {
    /// to be called in dispose for audio
    _recorder!.closeRecorder();
    _recorder = null;
  }
  
  @deprecated
  Future<String?> upload(String messageId) async {
    /// returns download url or null if recordingPath is null

    if (recordingPath == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('voice/$messageId.aac');
    
    final uploadTask = storageRef.putFile(File(recordingPath!));
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    recordingPath = null;

    return downloadUrl;
  }

  // Upload the image to the Express backend
  Future<void> send() async {
    if (recordingPath == null) return;

    final uri = Uri.parse('http://192.168.0.159:5000/upload');
    final request = http.MultipartRequest('POST', uri);

    // Add the file to the request
    final mimeTypeData = lookupMimeType(recordingPath!)!.split('/');
    final file = await http.MultipartFile.fromPath(
      'media',  // Field name in your Express route
      recordingPath!,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );
    request.files.add(file);

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('File upload failed: ${response.statusCode}');
    }
  }
}