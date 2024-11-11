import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';
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

  Future<void> deleteVideo(String fileName) async {
    try {
      await firebaseApi.deleteVideo(fileName);
      setState(() {
        _videoFile.removeWhere((video) => video.name == fileName);
      });
    } catch (err) {
      print("Error while deleting video $err");
    }
  }

  Future<void> downloadVideo(String videoUrl) async {
    // Implement the logic to download the video file.
    // This could involve saving the file locally or opening the URL in the browser.
    print("Downloading video from $videoUrl");
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
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
      ),
      body: _isLoading
          ? Loader(context)
          : _videoFile.isEmpty
          ? noData("No Videos available")
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _videoFile.length,
          itemBuilder: (context, index) {
            final video = _videoFile[index];
            return VideoCard(
              videoFile: video,
              index: index,
              onDelete: () => deleteVideo(video.name),
              onDownload: () => downloadVideo(video.url),
            );
          },
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoFile videoFile;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const VideoCard({
    required this.videoFile,
    required this.index,
    required this.onDelete,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
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
                    child: VideoThumbnailWidget(videoUrl: videoFile.url),
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
                    'Uploaded by: ${videoFile.uploaderName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd-MMM-yyyy').format(videoFile.uploadTime)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Download Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.download, color: Colors.white),
                              onPressed: onDownload,
                              tooltip: 'Download',
                            ),
                          ),
                          SizedBox(width: 10),

                          // Delete Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: onDelete,
                              tooltip: 'Delete',
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class VideoThumbnailWidget extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnailWidget({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ),
      ),
    );
  }
}
