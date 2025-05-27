import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/pages/profile/profile.dart';
import '../consts/AppConts.dart';
import 'User.dart';

class RequestApi {
  Future<void> createRequest(String userId,
      List<Map<String, dynamic>> guardianData, BuildContext context) async {
    try {
      final String url = "$MAINURL/api/v3/request/createRequest";

      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("jwtToken");

      print("Request Api $guardianData");

      var body = {"userId": userId, "guardianData": guardianData};

      final response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Request send to guardian");
      } else {
        var output = json.decode(response.body);
        print("Error while sending request $output");
      }
    } catch (err) {
      print("Error during creating request $err");
    }
  }

  Future<List<Request>> getGuardianWithPhone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? phoneNumber = preferences.getString("phoneNumber");
    var token = preferences.getString("jwtToken");

    try {
      final String url = "$MAINURL/api/v3/request/gurdianWithPhoneNUmber";

      var body = {"phoneNumber": phoneNumber};

      final response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Fluttertoast.showToast(msg: "Requested fetched...");

        List<Request> users = (data['data'] as List)
            .map((user) => Request.fromJson(user['userId']))
            .toList();

        return users;
      } else {
        print("Error while getting requests");
        return [];
      }
    } catch (err) {
      print("Error during getting user $err");
      return [];
    }
  }

  Future<void> deleteRequest(
      List<Map<String, String>> data, BuildContext context) async {
    final String url = "$MAINURL/api/v3/request/deleteRequest";

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString("jwtToken");

    print(data);

    try {
      var body = {"updates": data};

      final response = await http.delete(Uri.parse(url),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Requests removed");
        Navigator.push(
            context,
            PageTransition(
                child: ProfilePage(),
                type: PageTransitionType.leftToRight,
                duration: Duration(milliseconds: 400)));
      } else {
        var output = json.decode(response.body);
        print("Error while updating status $output");
      }
    } catch (err) {
      print("Error while updating status $err");
    }
  }

  Future<void> updateRequestStatus(
      List<Map<String, String>> data, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userId = preferences.getString("userId");
      var token = preferences.getString("jwtToken");

      print("User data $data");
      final String url = "$MAINURL/api/v3/request/updateStatus";

      var body = {"updates": data};

      final response = await http.patch(Uri.parse(url),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Request Status modified");
        Navigator.push(
            context,
            PageTransition(
                child: ProfilePage(),
                type: PageTransitionType.leftToRight,
                duration: Duration(milliseconds: 400)));
      } else {
        var output = json.decode(response.body);
        print("Error while updating status $output");
      }
    } catch (err) {
      print("Error while updating status $err");
    }
  }

  Future<List<UserAssignedGuardian>> getGuardianByUserId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userId = preferences.getString("userId");
      var token = preferences.getString("jwtToken");

      final String url = "$MAINURL/api/v3/request/getUserbyId/$userId";

      var response =
      await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<UserAssignedGuardian> guardians = (data['data'] as List)
            .map((json) => UserAssignedGuardian.fromJson(json))
            .toList();

        return guardians;
      } else {
        var data = json.decode(response.body);
        print("error $data");
        return [];
      }
    } catch (err) {
      print("Error while getting guardian by userId $err");
      return [];
    }
  }
}
