import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    // Listen for state changes such as buffering, play, pause, etc.
    _controller.addListener(() {
      setState(() {}); // Redraw the widget whenever the state changes
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Check if the video controller is initialized and ready to display the video
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              _buildBufferingIndicator(),  // Show buffering progress
              _buildPlayPauseButton(),      // Play/Pause button overlay
              _buildProgressBar(),          // Show playback progress
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),  // Show loading indicator until video is initialized
      ],
    );
  }

  // Buffering progress indicator
  Widget _buildBufferingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        value: _controller.value.isBuffering ? null : 0,  // Show if buffering
        valueColor: AlwaysStoppedAnimation(Colors.green), // Buffering color
      ),
    );
  }

  // Play/Pause button overlay
  Widget _buildPlayPauseButton() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54, // Semi-transparent background
        ),
        child: IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 50,
          ),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
        ),
      ),
    );
  }

  // Custom progress bar with scrubbing
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: VideoProgressIndicator(
        _controller,
        allowScrubbing: true,  // Allow scrubbing to seek to different positions
        colors: VideoProgressColors(
          playedColor: Colors.green,    // Color of the played portion
          bufferedColor: Colors.grey.shade400, // Color of the buffered portion
          backgroundColor: Colors.grey.shade800, // Background of the progress bar
        ),
        padding: EdgeInsets.all(0), // Remove padding for a cleaner look
      ),
    );
  }
}
