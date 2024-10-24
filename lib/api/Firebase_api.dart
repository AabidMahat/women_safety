import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/EmergencyCall.dart';

import '../Database/Database.dart';
import '../pages/LogIn/Login.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
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

    if (message.notification!.title == "Call Notification") {
      print("Sms*********************");
      emergencyCallApi.cancelSMS();
    }

    print(message.notification!.title);
    navigatorKey.currentState?.pushNamed("/home");
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
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');

    await ref.putFile(File(videoUrl));

    String downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> uploadAudio(String audioUrl) async {
    Reference ref = _storage.ref().child("recording/${DateTime.now()}.aac");

    await ref.putFile(File(audioUrl));

    String downloadUrl = await ref.getDownloadURL();

    return downloadUrl;
  }

  Future<List<VideoFile>> fetchVideos() async {
    final Reference storageRef = FirebaseStorage.instance.ref().child('videos');

    final ListResult result = await storageRef.listAll();

    final List<VideoFile> videoFile = [];

    for (var ref in result.items) {
      final String downloadUrl = await ref.getDownloadURL();
      final String name = ref.name;

      final FullMetadata metadata = await ref.getMetadata();

      final DateTime uploadTime = metadata.timeCreated ?? DateTime.now();

      videoFile
          .add(VideoFile(url: downloadUrl, name: name, uploadTime: uploadTime));
    }

    return videoFile;
  }

  Future<List<AudioFile>> fetchAudio() async {
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('recording');

    final ListResult result = await storageRef.listAll();

    final List<AudioFile> audioFiles = [];

    for (var ref in result.items) {
      final String downloadUrl = await ref.getDownloadURL();
      final String name = ref.name;

      final FullMetadata metadata = await ref.getMetadata();

      final DateTime uploadTime = metadata.timeCreated ?? DateTime.now();

      audioFiles
          .add(AudioFile(url: downloadUrl, name: name, uploadTime: uploadTime));
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
}
