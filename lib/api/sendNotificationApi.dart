import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/tokenApi.dart';

import '../consts/AppConts.dart';

class SendNotification {
  Future<void> sendNotification(String title, String message) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String firebaseToken = preferences.getString("firebaseToken")!;
      final String url = "${MAINURL}/api/v3/notification/sendNotification";

      var TokenBody = {
        "title": title,
        "body": message,
        "fcm_token": firebaseToken
      };


      print({
        TokenBody
      });

      var response = await http.post(Uri.parse(url),
          body: json.encode(TokenBody),
          headers: {"Content-Type": "application/json"});
      print(response.statusCode);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Notification Send");
      } else {
        var responseError = json.decode(response.body);
        print(responseError);
        Fluttertoast.showToast(msg: "Error While Sending Notification");
      }
    } catch (err) {
      print("Error while sending Notification $err");
      Fluttertoast.showToast(msg: "Error while sending notification");
    }
  }

  Future<void> sendVideoRecordingNotification() async {
    try {
      String url = "${MAINURL}/api/v3/notification/triggerVideoRecording";
      SharedPreferences preferences = await SharedPreferences.getInstance();

      String phoneNumber = preferences.getString("phoneNumber")!;
      String token = await TokenApi().getTokenByPhoneNumber(phoneNumber);

      print({token});

      var TokenBody = {
        "fcm_token": token,
        "title": "Video Recording",
        "body": "tap to turn on video recording",
        "duration": "30"
      };
      var response = await http.post(Uri.parse(url), body: TokenBody);
      print(response.statusCode);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Notification Send");
      } else {
        var responseError = json.decode(response.body);
        print(responseError);
        Fluttertoast.showToast(msg: "Error While Sending Notification");
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: "Error while sending notification");
    }
  }

  Future<void> triggerRecording() async {
    String url = "${MAINURL}/api/v3/notification/triggerRecording";
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String phoneNumber = preferences.getString("phoneNumber")!;
    String token = await TokenApi().getTokenByPhoneNumber(phoneNumber);

    print({token});

    var recordBody = {
      "fcm_token": token,
      "duration": "30",
      "title": "Audio Recording",
      "body": "Click to start Audio Recording"
    };
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode(recordBody),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Recording triggered successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed to trigger recording");
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: "Error while sending notification");
    }
  }
}
