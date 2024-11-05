import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/sendNotification.dart';
import 'package:women_safety/consts/AppConts.dart';
import 'package:women_safety/utils/SmsTemplate.dart';

class EmergencyCallApi {
  PhoneStateStatus? _callState;
  bool isCallAnswered = false; // Track if the call was answered
  SendNotification sendNotification = SendNotification();
  Timer? smsTimer;
  String? phoneNumber;

  void startListening() {
    PhoneState.stream.listen((PhoneState state) {
      _callState = state.status;
      print("*************************************************");
      phoneNumber = state.number;

      print("Phone Number $phoneNumber");

      if (_callState == PhoneStateStatus.CALL_STARTED) {
        if (phoneNumber != null && phoneNumber!.startsWith('+18')) {
          Fluttertoast.showToast(msg: "Your Route is being monitored");
          isCallAnswered = false;
        }
        return;
      }

      if (_callState == PhoneStateStatus.CALL_ENDED) {
        _onCallEnd();
      }

      if (_callState == PhoneStateStatus.CALL_INCOMING) {
        if (phoneNumber != null && phoneNumber!.startsWith('+18')) {
          Fluttertoast.showToast(msg: "Incoming call from Japan");
          isCallAnswered = false; // Mark call as not answered yet
        }
      }
    });
  }

  Future<void> _onCallEnd() async {
    if (!isCallAnswered) {
      if (phoneNumber != null && phoneNumber!.startsWith('+18')) {
        sendNotification.sendNotification(
            "Call Notification", "Tap to cancel SOS message (within 10 secs)",[]);

        smsTimer = Timer(Duration(seconds: 10), () {
          sendSMS();
        });
      }
    } else {
      print("Call was answered, notification not sent.");
    }
  }

  // Method to cancel the SMS
  void cancelSMS() {
    if (smsTimer != null && smsTimer!.isActive) {
      smsTimer!.cancel();
      Fluttertoast.showToast(msg: "SOS message canceled");
    }
  }

  Future<void> makeCall(String phoneNumber) async {
    final String url = "${MAINURL}/api/v3/notification/makeCall";
    try {
      var callBody = {"phoneNumber": phoneNumber};

      var response = await http.post(Uri.parse(url),
          body: json.encode(callBody),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Call Initiated successfully");
      } else {
        var responseError = json.decode(response.body);
        print(responseError);
        Fluttertoast.showToast(msg: "Error While Making Call");
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: "Error while sending notification");
    }
  }
}
