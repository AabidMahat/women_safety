import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/noData.dart';
import '../Database/Database.dart';
import '../api/Firebase_api.dart';
import '../home_screen.dart';
import '../widgets/customAppBar.dart';

class ShowAudios extends StatefulWidget {
  const ShowAudios({super.key});

  @override
  State<ShowAudios> createState() => _ShowAudiosState();
}

class _ShowAudiosState extends State<ShowAudios> {
  List<AudioFile> _audioFile = [];
  FirebaseApi firebaseApi = FirebaseApi();
  bool _isLoading = false;
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    fetchAudio();

    // Listen for changes in the audio position and duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _currentlyPlaying = null;
        _position = Duration.zero; // Reset progress when playback is complete
      });
    });
  }

  void showInfo() {
    Fluttertoast.showToast(msg: "Only 3 audios can be uploaded");
  }

  Future<void> fetchAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final List<AudioFile> audioFile = await firebaseApi.fetchAudio();

      setState(() {
        _audioFile = audioFile;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playPauseAudio(String url) async {
    if (_currentlyPlaying == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
      });
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlaying = url;
      });
    }
  }

  Future<void> deleteAudio(String filename) async {
    try {
      print("Button pressed");
      await firebaseApi.deleteAudio(filename);
      setState(() {
        _audioFile.removeWhere((audio) => audio.name == filename);
      });
    } catch (err) {
      print("Error while deleting audio $err");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Audio Files",
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
        leadingIcon: Icons.arrow_back,
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
      ),
      body: _isLoading
          ? Loader(context)
          : _audioFile.isEmpty
          ? Center(
        child: noData("No Audio Available"),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: _audioFile.length,
          itemBuilder: (context, index) {
            final audioFile = _audioFile[index];
            final isPlaying = _currentlyPlaying == audioFile.url;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        title: Text(
                          audioFile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.white12,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              'Uploaded by: ${audioFile.uploaderName}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('dd-MMM-yyyy')
                                      .format(audioFile.uploadTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('hh:mm a')
                                      .format(audioFile.uploadTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 45,
                            color: Colors.green.shade900,
                          ),
                          onPressed: () =>
                              _playPauseAudio(audioFile.url),
                        ),
                      ),
                      if (isPlaying)
                        Slider(
                          activeColor: Colors.green.shade900,
                          inactiveColor: Colors.black,
                          min: 0,
                          max: _duration.inSeconds.toDouble(),
                          value: _position.inSeconds.toDouble(),
                          onChanged: (value) async {
                            final newPosition =
                            Duration(seconds: value.toInt());
                            await _audioPlayer.seek(newPosition);
                            setState(() {
                              _position = newPosition;
                            });
                          },
                        ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 00,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade900,
                        size: 24,
                      ),
                      onPressed: () async {
                        await deleteAudio(audioFile.name);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}
