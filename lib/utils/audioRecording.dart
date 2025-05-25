import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety/api/User.dart';

import '../api/Firebase_api.dart';

class AudioRecordingService {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  FirebaseApi firebaseApi = FirebaseApi();
  String ?audioPath;

  Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();

    //   Request microphone permission
    if (await Permission.microphone.request().isGranted) {
      Fluttertoast.showToast(msg: "Microphone permission granted");
    } else {
      throw RecordingPermissionException("Microphone permission not granted");
    }
  }

  Future<void> startRecording() async {
    if (_recorder == null) return;
    // Generate file path for the recording
    audioPath = '${DateTime.now().millisecondsSinceEpoch}_audioRecord.aac';

    await _recorder!.startRecorder(toFile: audioPath);

    _isRecording = true;
    Fluttertoast.showToast(msg: "Recording started...");
  }

  Future<void> stopRecording() async {
    if (_recorder == null || !_isRecording) return;
    audioPath = await _recorder!.stopRecorder();
    print(audioPath);
    _isRecording = false;
    Fluttertoast.showToast(msg: "Recording Completed...");

    if (audioPath != null) {
      String audioUrl = await firebaseApi.uploadAudio(audioPath!);
      await UserApi().addAudioOrVideo({"audioUrl":audioUrl});
    } else {
      Fluttertoast.showToast(msg: "Recording file not found!");
    }

    await disposeRecorder();
  }

  Future<void> disposeRecorder() async {
    await _recorder!.closeRecorder();
    _recorder = null;
  }
}
