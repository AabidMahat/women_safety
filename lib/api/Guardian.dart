import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/pages/profile/profile.dart';

import '../consts/AppConts.dart';
import 'package:http/http.dart' as http;

class GuardianApi {
  Future<Guardian?> getGuardian() async {
    Guardian guardian;
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final userId = preferences.getString("userId");

      print("Guardian Api $userId");

      final String url = "${MAINURL}/api/v3/guardian/fetchGuardian/${userId}";

      var response = await http.get(Uri.parse(url));
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var guardianData = body['data'];

        print("Guardian $guardianData");

        guardian = Guardian.fromJson(guardianData);
        Fluttertoast.showToast(msg: "Guardian data fetched successfully");
        return guardian;
      } else {
        Fluttertoast.showToast(msg: "Error: Unexpected data format");
        return null;
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
      return null;
    }
  }

  Future<void> updateGuardian(var updateBody, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final userId = preferences.getString("userId");

      final String url = "${MAINURL}/api/v3/guardian/updateGuardian/${userId}";

      var response = await http.patch(Uri.parse(url),
          body: json.encode(updateBody),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Guardian updated Successfully");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
      } else {
        Fluttertoast.showToast(msg: "Error: Unexpected data format");
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
    }
  }
}
