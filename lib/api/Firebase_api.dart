import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/EmergencyCall.dart';
import 'package:women_safety/api/User.dart';
import 'package:women_safety/api/tokenApi.dart';

import '../Database/Database.dart';
import '../main.dart';
import '../utils/StartVideoRecording.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
  StartVideoRecording _videoRecordingService = StartVideoRecording();

  // Instance of Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  EmergencyCallApi emergencyCallApi = EmergencyCallApi();
  String? FIREBASE_TOKEN;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Android notification channel for important notifications
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel',
    "High Importance Notifications",
    description: "This channel is used for important notifications",
    importance: Importance
        .high, // Use 'Importance.high' to ensure notifications are displayed prominently
  );

  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print(message.data);
    if (message.data['action'] == "startRecording") {
      print("Navigating to video Player");
      _videoRecordingService.handleVideoRecordingMessage(message);
    } else if (message.data['action'] == "audioRecording") {
      _videoRecordingService.handleAudioRecordingMessage(message);
    } else if (message.notification!.title == "Call Notification") {
      emergencyCallApi.cancelSMS();
    } else {
      navigatorKey.currentState?.pushNamed("/home");
    }
  }

  // Function to initialize notifications
  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle the message when the app is initially opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Handle the message when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Listen to messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;

      if (notification == null) return;

      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/women_safety',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initLocalNotification() async {
    const android = AndroidInitializationSettings('@drawable/women_safety');
    const settings = InitializationSettings(android: android);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == null) return;
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handleMessage(message);
      },
    );

    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final firebaseToken = await _firebaseMessaging.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("firebaseToken", firebaseToken!);
    print("Firebase Token: $firebaseToken");

    await _firebaseMessaging.subscribeToTopic('recording');
    await _firebaseMessaging.subscribeToTopic('videoRecording');

    print("Suscribed to topic");

    await initPushNotification();
    await initLocalNotification();
  }

  Future<String> uploadVideo(String videoUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? username = preferences.getString("username");

    Reference userVideoRef = _storage.ref().child('videos/$username');

    final ListResult result = await userVideoRef.listAll();

    List<Map<String, dynamic>> userVideos = [];

    // Collect metadata along with reference
    for (var ref in result.items) {
      final FullMetadata metadata = await ref.getMetadata();

      if (metadata.customMetadata?['userId'] == userId) {
        userVideos.add({
          'ref': ref,
          'timeCreated': metadata.timeCreated,
        });
      }
    }

    // Sort the list by timeCreated
    userVideos.sort((a, b) {
      return a['timeCreated'].compareTo(b['timeCreated']);
    });

    // Check if there are more than 3 videos and delete the oldest
    if (userVideos.length >= 3) {
      await userVideos.first['ref'].delete();
      Fluttertoast.showToast(msg: "Deleted oldest video for user $username");
    }

    // Reference for the new video upload
    Reference ref = userVideoRef
        .child('${username}_${DateTime.now().toIso8601String()}.mp4');
    final SettableMetadata metadata =
        SettableMetadata(customMetadata: {'userId': userId!});

    await ref.putFile(File(videoUrl), metadata);

    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteVideo(String fileName) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? username = preferences.getString("username");

      Reference videoRef = _storage.ref().child('videos/$username/$fileName');

      await videoRef.delete();

      Fluttertoast.showToast(msg: "Video deleted successfully");
    } catch (err) {
      print("Failed to delete video : $err");
      Fluttertoast.showToast(msg: "Failed to delete video : $err");
    }
  }

  Future<void> deleteAudio(String filename) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? username = preferences.getString("username");

      Reference audioRef =
          _storage.ref().child("recording/$username/$filename");

      await audioRef.delete();

      Fluttertoast.showToast(msg: "Audio deleted successfully");
    } catch (err) {
      print("Failed to delete audio : $err");
      Fluttertoast.showToast(msg: "Failed to delete audio : $err");
    }
  }

  Future<String> uploadAudio(String audioUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String? username = preferences.getString("username");

    Reference userAudioRef = _storage.ref().child("recording/${username}");

    final ListResult result = await userAudioRef.listAll();

    List<Map<String, dynamic>> userAudios = [];

    for (var ref in result.items) {
      final FullMetadata metadata = await ref.getMetadata();

      if (metadata.customMetadata?['userId'] == userId) {
        userAudios.add({
          'ref': ref,
          'timeCreated': metadata.timeCreated,
        });
      }
    }

    userAudios.sort((a, b) {
      return a['timeCreated'].compareTo(b['timeCreated']);
    });

    if (userAudios.length >= 3) {
      await userAudios.first['ref'].delete();
      Fluttertoast.showToast(msg: "Deleted oldest audio for user $username");
    }

    Reference ref = userAudioRef
        .child("${username}_${DateTime.now().toIso8601String()}.aac");

    final SettableMetadata metadata =
        SettableMetadata(customMetadata: {'userId': userId!});

    await ref.putFile(File(audioUrl), metadata);

    String downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  Future<List<VideoFile>> fetchVideos() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('videos/$username');

    final ListResult result = await storageRef.listAll();

    final List<VideoFile> videoFile = [];

    for (var ref in result.items) {
      final String downloadUrl = await ref.getDownloadURL();
      final String name = ref.name;

      final FullMetadata metadata = await ref.getMetadata();

      final String userId = metadata.customMetadata?['userId'] ?? ' ';

      final String userName = await UserApi().getUserDetails(userId);

      final DateTime uploadTime = metadata.timeCreated ?? DateTime.now();

      videoFile.add(VideoFile(
          url: downloadUrl,
          name: name,
          uploadTime: uploadTime,
          uploaderName: userName));
    }

    return videoFile;
  }

  Future<List<AudioFile>> fetchAudio() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? username = preferences.getString("username");
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('recording/${username}');

    final ListResult result = await storageRef.listAll();

    final List<AudioFile> audioFiles = [];

    for (var ref in result.items) {
      final String downloadUrl = await ref.getDownloadURL();
      final String name = ref.name;
      final FullMetadata metadata = await ref.getMetadata();
      final String userId = metadata.customMetadata?['userId'] ?? "";

      final String userName = await UserApi().getUserDetails(userId);

      final DateTime uploadTime = metadata.timeCreated ?? DateTime.now();

      audioFiles.add(AudioFile(
          url: downloadUrl,
          name: name,
          uploadTime: uploadTime,
          uploaderName: userName));
    }
    return audioFiles;
  }

  Future<String> saveProfileImage(String filePath) async {
    try {
      Reference ref = _storage.ref().child("images/${DateTime.now()}.jpg");

      await ref.putFile(File(filePath));

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (err) {
      print("Failed to upload image: $err");
      return "";
    }
  }

  Future<void> checkAndUpdateFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString("firebaseToken");
    String? userId = prefs.getString("userId");
    String? currentToken = await FirebaseMessaging.instance.getToken();

    print({"current": currentToken, "stored": storedToken});

    if (currentToken != null && userId != null) {
      await prefs.setString('firebaseToken', currentToken);

      await TokenApi().addOrUpdateFCMToken(userId, currentToken);

      print("FCM token saved to backend");
    } else {
      print("Failed to get FCM token");
    }
  }
}
