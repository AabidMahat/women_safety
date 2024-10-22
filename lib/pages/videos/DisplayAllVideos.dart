import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import '../../api/Firebase_api.dart';
import 'PlayRecordedVideo.dart';

class ShowAllVideo extends StatefulWidget {
  const ShowAllVideo({super.key});

  @override
  State<ShowAllVideo> createState() => _ShowAllVideoState();
}

class _ShowAllVideoState extends State<ShowAllVideo> {
  List<VideoFile> _videoFile = [];
  FirebaseApi firebaseApi = FirebaseApi();
  bool _isLoading = false;

  Future<void> fetchVideos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final List<VideoFile> videoFile = await firebaseApi.fetchVideos();

      setState(() {
        _videoFile = videoFile;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchVideos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Uploaded Videos",
        onPressed: () {},
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.green.shade900,
          strokeWidth: 5,
        ),
      )
          : _videoFile.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No videos available",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _videoFile.length,
          itemBuilder: (context, index) {
            return VideoCard(videoFile: _videoFile[index], index: index);
          },
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoFile videoFile;
  final int index;

  const VideoCard({required this.videoFile, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10), // Add margin between cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerWidget(videoUrl: videoFile.url),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoThumbnailWidget(videoUrl: videoFile.url), // Placeholder for video thumbnail
              ),
              SizedBox(height: 12),
              Text(
                videoFile.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Date: ${DateFormat('dd-MMM-yyyy').format(videoFile.uploadTime)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoThumbnailWidget extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnailWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder widget for the video thumbnail.
    // You can use `flutter_video_info` or similar packages to generate video thumbnails.
    return AspectRatio(
      aspectRatio: 16 / 9, // Maintain a good video aspect ratio
      child: Container(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ),
      ),
    );
  }
}
