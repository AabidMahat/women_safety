import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/Firebase_api.dart';
import 'package:women_safety/pages/profile/profile.dart';

import '../consts/AppConts.dart';
import 'package:http/http.dart' as http;

class GuardianApi {
  FirebaseApi firebaseApi = FirebaseApi();

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

        print("guardian ${guardianData}");
        guardian = Guardian.fromJson(guardianData);

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

  Future<void> updateUserList(List<String> assignedUserId, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userId = preferences.getString("userId");


      print("UserIds ${assignedUserId}");

      String url = "$MAINURL/api/v3/guardian/updateUserList/$userId";

      var body = {"userId": assignedUserId};
      var response = await http.patch(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Update sucessful");
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: ProfilePage(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
      }else{
        var data = json.decode(response.body);
        print("Error while updating data ${data['message']}");
      }
    } catch (err) {
      print("Error while updating user list $err");
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

  Future<String> pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String downloadUrl = await firebaseApi.saveProfileImage(image.path);
      return downloadUrl;
    } else {
      Fluttertoast.showToast(msg: "Error while storing image");
      return "";
    }
  }
}
