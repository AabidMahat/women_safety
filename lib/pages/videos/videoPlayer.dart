import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/VideoRecording.dart';


class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  VideoRecordingService _recordingService = VideoRecordingService();

  @override
  void initState() {
    super.initState();
    _initializeCameraAndStartRecording();
  }

  Future<void> _initializeCameraAndStartRecording() async {
    await _recordingService.initializeCamera();
    setState(() {});  // Update the UI once the camera is initialized

    await _recordingService.startVideoRecording(context);
  }

  @override
  void dispose() {
    _recordingService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Display the camera preview
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: _recordingService.buildCameraPreview(),
            ),
          ),
        ],
      ),
    );
  }
}
