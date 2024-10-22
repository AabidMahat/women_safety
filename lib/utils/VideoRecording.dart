import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../pages/videos/videoPreview.dart';

class VideoRecordingService{
  CameraController ? _cameraController;
  late List<CameraDescription> _cameras;
  bool isRecording = false;


  Future<void> initializeCamera()async{
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.low);

    await _cameraController?.initialize();
  }

  Future<void> startVideoRecording(BuildContext context)async{
    if(_cameraController!=null && !_cameraController!.value.isRecordingVideo){
      final directory = await getApplicationDocumentsDirectory();

      final videoPath =  '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _cameraController!.startVideoRecording();
      isRecording = true;

      // Automatically stop recording after 30 seconds
      Timer(Duration(seconds: 30), () async {
        print("Startrecording part");
        if (isRecording) {
          print("Triggered stop recording");
          await stopRecording(context);
        }
      });
    }
  }

  Future<void> stopRecording(BuildContext context)async{
    print("Recording State $isRecording");
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo){
      print("Stop recording part is called");

      final videoFile = await _cameraController!.stopVideoRecording();
      isRecording = false;

      Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPreview(videoFile: File(videoFile.path), videoPath: videoFile.path)));
    }
  }
  Widget buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController!);
  }

  void disposeCamera() {
    _cameraController?.dispose();
  }


}