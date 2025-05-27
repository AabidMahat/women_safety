import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/Firebase_api.dart';

import '../Database/Database.dart';
import '../consts/AppConts.dart';
import '../home_screen.dart';

class UserApi {
  Future<List<UserData>> getUsers() async {
    try {
      final String url = "${MAINURL}/api/v3/user/getAllUsers";
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");

      var response = await http.post(
          Uri.parse(url),
        headers:{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );
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

  Future<Map<String, dynamic>> getUser(String userId) async {
    String url =
        "$MAINURL/api/v3/user/getUser/$userId"; // URL to fetch the user data
    print("Fetching user with ID: $userId");



    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");

      var response = await http.post(
          Uri.parse(url),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        return body;
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print("Error fetching user: $body");
        return {}; // Return an empty map in case of an error
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      print("Exception fetching user: $err");
      return {}; // Return an empty map if there's an exception
    }
  }

  Future<UserData> getUserProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");

    final String url =
        "$MAINURL/api/v3/user/getUser/$userId"; // API endpoint to fetch user data
    print("Fetching user with ID: $userId");

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");

      var response = await http.post(
          Uri.parse(url),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        print("User data: $body");

        return UserData.fromJson(body['data']);
      } else {
        final body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print("Error fetching user: $body");

        return UserData.defaultUser();
      }
    } catch (err) {
      Fluttertoast.showToast(msg: "Error: ${err.toString()}");
      print("Exception fetching user: $err");

      return UserData.defaultUser();
    }
  }

  Future<List<String>> getGuardianName(List<String> guardianIds) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var token = preferences.getString("jwtToken");

    try {
      final String url = "${MAINURL}/api/v3/guardian/getGuardians";
      var response = await http.post(
        Uri.parse(url),
        headers:{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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

  Future<void> addAudioOrVideo(Map<String, String> data) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? userId = preferences.getString("userId");

      var token = preferences.getString("jwtToken");

      final String url = "${MAINURL}/api/v3/user/addAudioAndVideo/${userId}";

      var response = await http.patch(Uri.parse(url),
          body: json.encode(data),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Data Added");
      } else {
        Fluttertoast.showToast(msg: "Error while adding data");
      }
    } catch (err) {
      print("Exception occurred: $err");
      Fluttertoast.showToast(msg: "Error fetching users: $err");
    }
  }

  Future<String> getUserDetails(String userId) async {
    try {
      String url = "$MAINURL/api/v3/user/getUser/$userId";

      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");

      var response = await http.post(
          Uri.parse(url),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );

      print("Response details ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        return data['data']['name'];
      } else {
        return "Unknown User";
      }
    } catch (err) {
      print("Error $err");
      return "Unknown User";
    }
  }

  Future<List<Request>> getAssignedUserToGuardian() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? phoneNumber = preferences.getString("phoneNumber");
      String url = "$MAINURL/api/v3/user/gurdianWithPhoneNUmber";
      var token = preferences.getString("jwtToken");

      var body = {"phoneNumber": phoneNumber};

      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Fluttertoast.showToast(msg: "Requested fetched...");

        List<Request> users = (data['data'] as List)
            .map((user) => Request.fromJson(user))
            .toList();

        return users;
      } else {
        return [];
      }
    } catch (err) {
      print("Error in assigned user $err");
      return [];
    }
  }

  Future<List<String>> getUserName(List<String> userId) async {
    try {
      final String url = "${MAINURL}/api/v3/user/getUsers";
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");

      var response = await http.post(Uri.parse(url),
          body: json.encode({"userId": userId}),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        List<String> userNames = [];

        for (var user in body['data']) {
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

  // Method to update a user
  Future<void> updateUser(
      Map<String, dynamic> updatedData, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    String url = "$MAINURL/api/v3/user/updateUser/$userId";
    try {
      var response = await http.patch(
        Uri.parse(url), // Using PATCH method
        body: json.encode(updatedData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: "User updated successfully");
        print(body);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print(body);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  // Method to delete a user
  Future<void> deleteUser(String userId, BuildContext context) async {
    String url = "$MAINURL/api/v3/user/deleteUser/$userId";

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var token = preferences.getString("jwtToken");

    try {
      var response = await http.delete(Uri.parse(url), headers:{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: "User deleted successfully");
        print(body);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print(body);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  // Method to add guardians
  Future<void> addGuardian(String userId, Map<String, dynamic> guardianData,
      BuildContext context) async {
    String url = "${MAINURL}/api/v3/user/addGuardian/$userId";
    print("UserID is: $userId");
    print("Guardian Data: $guardianData");

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var token = preferences.getString("jwtToken");

    try {
      var response = await http.patch(
        Uri.parse(url),
        body: json.encode({
          "guardian": guardianData['guardian'],
        }),
        headers:{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Guardian updated successfully");
        print("Gaurdian updated Successfully");
      } else {
        print("Error Response: ${response.body}");
        Fluttertoast.showToast(
            msg: json.decode(response.body)['message'] ??
                "Failed to update guardian");
      }
    } catch (err) {
      print("Failed to update guardian: $err");
      Fluttertoast.showToast(msg: "Failed to update guardian");
    }
  }

  Future<String> pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String downloadUrl = await FirebaseApi().saveProfileImage(image.path);
      return downloadUrl;
    } else {
      Fluttertoast.showToast(msg: "Error while storing image");
      return "";
    }
  }

  Future<List<String>> getGuardianNumber(String userId) async {
    try {
      String url = "${MAINURL}/api/v3/user/allGuardianNumber";

      SharedPreferences preferences = await SharedPreferences.getInstance();

      var token = preferences.getString("jwtToken");


      List<String> numbers = [];
      var body = {"userId": userId};

      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers:{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Guardian Numbers ${data['data']} ");

        // Convert List<dynamic> to List<String>
        numbers = List<String>.from(data['data']);


        return numbers;
      } else {
        return numbers;
      }
    } catch (err) {
      Fluttertoast.showToast(msg: "Error while getting response");
      return [];
    }
  }
}
