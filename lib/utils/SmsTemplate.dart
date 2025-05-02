import 'dart:convert';

import 'package:background_sms/background_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/User.dart';

Future<void> sendSMS() async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String phoneNumber = preferences.getString("phoneNumber")!;
    String userId = preferences.getString("userId")!;

    List<String> numbers = await UserApi().getGuardianNumber(userId);

    String? position = preferences.getString("userLocation");

    print("Position ${json.decode(position!)}");

    Map<String, dynamic> positionMap = json.decode(position!);

    final mapsLink =
        'https://www.google.com/maps/?q=${positionMap['latitude']},${positionMap['longitude']}';

    print(mapsLink);

    // Construct a more detailed message
    final detailedMessage =
        "I'm in trouble and need help! Here is my current location: $mapsLink. ";


    for(String number in numbers){
      await BackgroundSms.sendMessage(
        phoneNumber: number,
        message: detailedMessage,
      ).then((SmsStatus status) {
        if (status == SmsStatus.sent) {
          Fluttertoast.showToast(msg: "Message Sent");
        } else {
          Fluttertoast.showToast(msg: "Failed to send SMS");
        }
      });
    }


  } catch (e) {
    print(e);
    Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
  }
}
