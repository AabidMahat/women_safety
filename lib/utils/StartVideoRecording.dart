
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


import '../main.dart';
import '../pages/LogIn/Login.dart';
import '../pages/videos/videoPlayer.dart';
import 'audioRecording.dart';

class StartVideoRecording {
  void handleVideoRecordingMessage(RemoteMessage? message) {
    print(message?.data);

    if (message == null) return;

    if (message.data.containsKey('action') &&
        message.data['action'] == 'startRecording') {
      // Ensure navigator key has a valid state before navigating

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => VideoPlayer(),
        ),
      );
    }
  }

  void handleAudioRecordingMessage(RemoteMessage? message) async{
    if (message == null) return;

    if (message.data.containsKey('action') &&
        message.data['action'] == 'audioRecording') {

      AudioRecordingService audioRecordingService = AudioRecordingService();

      await audioRecordingService.initRecorder();
      await audioRecordingService.startRecording();

      Future.delayed(Duration(minutes: 1),()async{
        await audioRecordingService.stopRecording();
      });
    }
  }
}
