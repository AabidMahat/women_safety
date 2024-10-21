import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/consts/AppConts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class FeedbackApi {
  List<FeedbackData> _feedback = [];
  IOWebSocketChannel? _webSocketChannel; // Changed to nullable
  final StreamController<FeedbackData> _streamController =
      StreamController<FeedbackData>.broadcast();
  String? userId;

  Stream<FeedbackData> get feedbackStream => _streamController.stream;

  Future<bool> createFeedback(
      LatLng location, String comment, String category) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("userId");
    bool isSubmitted = false;
    try {
      final String url = "${MAINURL}/api/v3/feedback/sendFeedback";
      // final String url = "http://10.0.2.2:3000/api/v3/feedback/sendFeedback";

      var feedbackBody = {
        "location": {
          "latitude": location.latitude,
          "longitude": location.longitude,
        },
        "category": category,
        "comment": comment,
        "userId": userId
      };

      var response = await http.post(
        Uri.parse(url),
        body: json.encode(feedbackBody),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        isSubmitted = true;
        Fluttertoast.showToast(msg: "Thank you for your valuable feedback");
        print(json.decode(response.body));
        return isSubmitted;
      } else {
        Fluttertoast.showToast(msg: "Error while submitting feedback");
        var responseBody = json.decode(response.body);
        print(responseBody);
        return isSubmitted;
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return isSubmitted;
    }
  }

  Future<void> getAllFeedback() async {
    final String url = "${MAINURL}/api/v3/feedback/getAllFeedback";
    // final String url = "http://10.0.2.2:3000/api/v3/feedback/getAllFeedback";
    print("called");
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        print("Response Body $responseBody");

        _feedback = List<FeedbackData>.from(
            responseBody['data'].map((item) => FeedbackData.fromJson(item)));

        // Getting real-time feedback
        _webSocketChannel =
            IOWebSocketChannel.connect('${WEBSOCKETURL}/feedback');
        // _webSocketChannel = IOWebSocketChannel.connect('ws://10.0.2.2:3000/feedback');

        _webSocketChannel!.sink.add(jsonEncode({"type": "feedbacks"}));

        _webSocketChannel!.stream.listen((message) {
          var data = jsonDecode(message);

          print("Message From Websocket $data");

          if (data['status'] == 'NewFeedback') {
            var newFeedback = FeedbackData.fromJson(data['data']);

            _feedback.add(newFeedback);
            _streamController.add(newFeedback);
            Fluttertoast.showToast(msg: "New Feedback Received");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "Error while submitting feedback");
        var responseBody = json.decode(response.body);
        print(responseBody);
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  List<FeedbackData> getFeedBackData() {
    return _feedback;
  }

  void closeWebSocket() {
    _webSocketChannel?.sink.close(); // Null-aware operator used
  }
}
