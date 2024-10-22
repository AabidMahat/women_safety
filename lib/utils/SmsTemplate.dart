import 'dart:convert';

import 'package:background_sms/background_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/Permission.dart';

Future<void> sendSMS() async {
  try {
    PermissionApi permissionApi = PermissionApi();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String phoneNumber = preferences.getString("phoneNumber")!;

    String? position = preferences.getString("userLocation");

    print("Position ${json.decode(position!)}");

    Map<String, dynamic> positionMap = json.decode(position!);

    final mapsLink =
        'https://www.google.com/maps/?q=${positionMap['latitude']},${positionMap['longitude']}';

    print(mapsLink);

    // Construct a more detailed message
    final detailedMessage =
        "I'm in trouble and need help! Here is my current location: $mapsLink. ";

    await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: detailedMessage,
    ).then((SmsStatus status) {
      if (status == SmsStatus.sent) {
        Fluttertoast.showToast(msg: "Message Sent");
      } else {
        Fluttertoast.showToast(msg: "Failed to send SMS");
      }
    });
  } catch (e) {
    print(e);
    Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
  }
}
