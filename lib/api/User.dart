import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/Database.dart';
import '../consts/AppConts.dart';

class UserApi {
  Future<List<UserData>> getUsers() async {
    try {
      final String url = "${MAINURL}/api/v3/user/getAllUsers";

      var response = await http.post(Uri.parse(url));
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['status'] == 'success' && body['data'] is List) {
          List<UserData> users = (body['data'] as List)
              .map((userData) => UserData.fromJson(userData))
              .toList();
          Fluttertoast.showToast(msg: "Users fetched successfully");
          return users;
        } else {
          print("Unexpected data format: $body");
          Fluttertoast.showToast(msg: "Error: Unexpected data format");
          return [];
        }
      } else {
        var responseError = json.decode(response.body);
        print("Error response: $responseError");
        Fluttertoast.showToast(
            msg:
                "Error fetching users: ${responseError['message'] ?? 'Unknown error'}");
        return [];
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
      return [];
    }
  }

  Future<List<String>> getGuardianName(List<String> guardianIds) async {
    try {
      final String url = "${MAINURL}/api/v3/guardian/getGuardians";
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"guardianIds": guardianIds}),
      );

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        List<String> guardiansName = [];
        for (var guardian in body['data']) {
          guardiansName.add(guardian['name']);
        }
        return guardiansName;
      } else {
        var responseError = json.decode(response.body);
        print("Error response: $responseError");
        Fluttertoast.showToast(
            msg:
                "Error fetching users: ${responseError['message'] ?? 'Unknown error'}");
        return [];
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
      return [];
    }
  }

  Future<List<String>> getUserName(List<String> userId) async {
    try {
      final String url = "${MAINURL}/api/v3/user/getUsers";
      var response = await http.post(Uri.parse(url),
          body: json.encode({"userId": userId}),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        List<String> userNames = [];

        for(var user in body['data']){
          userNames.add(user['name']);
        }
        return userNames;

      } else {
        var responseError = json.decode(response.body);
        print("Error response: $responseError");
        Fluttertoast.showToast(
            msg:
                "Error fetching users: ${responseError['message'] ?? 'Unknown error'}");
        return [];
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
      return [];
    }
  }
}
