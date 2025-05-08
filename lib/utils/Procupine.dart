import 'package:audioplayers/audioplayers.dart';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../consts/AppConts.dart';
import '../home_screen.dart';


class VoiceCommand extends StatefulWidget {
  const VoiceCommand({super.key});

  @override
  State<VoiceCommand> createState() => _VoiceCommandState();
}

class _VoiceCommandState extends State<VoiceCommand> {
  PorcupineManager? _porcupineManager;
  bool _speechEnable = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  bool _isRinging = false;


  final List<String> _keywordAsset = ["assets/Help-Me_en_android_v3_0_0.ppn","assets/Save-Me_en_android_v3_0_0.ppn"];
  final String _accessKey = PICOVOICE_API_KEY;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestMicrophonePermission();
    print('Initializing Porcupine...');
    initPorcupine();
  }

  void requestMicrophonePermission()async{
    await PermissionApi().requestRecordAuidoPermission();
  }

  void initPorcupine() async {
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        _accessKey,
        _keywordAsset,
        _wakeWordCallback,
      );
      await _porcupineManager?.start();
      print('Porcupine initialized and listening...');
    } on PorcupineException catch (err) {
      Fluttertoast.showToast(msg: 'Error: ${err.message}');
    }
  }

  void _wakeWordCallback(int keywordIndex) {

    print("Wake word detected: $keywordIndex");
    if (keywordIndex == 0 || keywordIndex==1) {
      // Keyword detected
      _sendEmergencySMS();
    }
  }

  Future<void> _sendEmergencySMS() async {
    try {
      Position position = await _determinePosition();
      final mapsLink =
          'https://www.google.com/maps/?q=${position.latitude},${position.longitude}';

      final detailedMessage =
          "I'm in trouble and need help! Here is my current location: $mapsLink. Please come as soon as possible.";

      String guardianPhoneNumber = '7559153594'; // Replace with the actual phone number

      await BackgroundSms.sendMessage(
        phoneNumber: guardianPhoneNumber,
        message: detailedMessage,
        simSlot: 1,
      ).then((SmsStatus status) {
        if (status == SmsStatus.sent) {
          Fluttertoast.showToast(msg: "Emergency message sent!");
          setState(() {
            _isRinging = true;
          });
          _playBeepSound();
        } else {
          Fluttertoast.showToast(msg: "Failed to send emergency message.");
        }
      });
    } catch (e) {
      print("SMS Error: $e");
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  Future<void> _playBeepSound() async {
    while(_isRinging) {
      await _audioPlayer.play(AssetSource("alert.mp3"));
      await _audioPlayer.onPlayerComplete.first; // Wait until the sound finishes playing
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied.');
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied.');
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }



  @override
  void dispose() {
    _porcupineManager?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white,
    appBar: customAppBar(
      "Voice Command",
      leadingIcon: Icons.arrow_back,
      backgroundColor: Colors.green.shade900,
      textColor: Colors.white,
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: HomeScreen(),
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 400),
          ),
        );
      },
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),

          // Mic inside a circular background
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade100,
            ),
            child: Icon(
              Icons.mic_rounded,
              size: 80,
              color: Colors.green.shade800,
            ),
          ),

          SizedBox(height: 30),

          // Listening Text
          Text(
            'Listening...',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),

          SizedBox(height: 10),

          // Instruction
          Text(
            'Speak your command clearly',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          Spacer(),

          // Words Spoken Output
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _wordsSpoken.isEmpty ? "Waiting for your voice..." : _wordsSpoken,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Confidence Indicator
          if (_confidenceLevel > 0) ...[
            Text(
              'Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: _confidenceLevel,
              backgroundColor: Colors.green.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ],

          Spacer(),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _isRinging = false;
        });
      },
      backgroundColor: Colors.redAccent,
      icon: Icon(Icons.volume_off, color: Colors.white),
      label: Text(
        'Mute',
        style: TextStyle(color: Colors.white),
      ),
    ),
    );


  }
}
