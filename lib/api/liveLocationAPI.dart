import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

import '../consts/AppConts.dart';

class GuardianAPI {
  IOWebSocketChannel? _webSocketChannel;
  final StreamController<String> _locationController =
      StreamController<String>();

  Stream<String> get locationStream => _locationController.stream;
  String? userId;

  Future<void> init() async {
    await getUserId();
    connectWebSocket();
  }

  Future<void> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString("userid");
  }

  void connectWebSocket() {
    _webSocketChannel =
        IOWebSocketChannel.connect('${WEBSOCKETURL}/live-location');

    // Listen for incoming messages
    _webSocketChannel!.stream.listen((message) {
      var data = jsonDecode(message);
      if (data['status'] == "Success") {
        String locationData = jsonEncode(data['data']);
        print(locationData);
        _locationController.add(locationData);
      }
    }, onError: (error) {
      print("WebSocket error: $error");
    }, onDone: () {
      print("WebSocket closed");
      _locationController.close(); // Close the stream on done
    });
    print("User ID $userId");
    // Send an initial message if necessary
    if (userId != null) {
      _webSocketChannel!.sink.add(jsonEncode(
          {"userId": userId, "type": "singleLocation"}));
    } else {
      print("Error: userId is null");
    }

    // Start polling for updates
    startPolling();
  }

  void startPolling() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (userId != null) {
        _webSocketChannel?.sink.add(jsonEncode(
            {"userId": userId, "type": "singleLocation"}));
      } else {
        print("Error: userId is null during polling");
      }
    });
  }

  void closeConnection() {
    _webSocketChannel?.sink.close();
  }
}
