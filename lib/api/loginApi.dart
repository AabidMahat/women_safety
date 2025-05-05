import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../Database/Database.dart';
import '../Pages/otpScreen.dart';
import '../consts/AppConts.dart';
import '../home_screen.dart';
import '../pages/LogIn/Login.dart';

class LoginApi {
  Future<void> login(
      String phoneNumber, String passworrd, BuildContext context) async {
    String url = "$MAINURL/api/v3/user/logIn";
    try {
      var body = {"phoneNumber": phoneNumber, "password": passworrd};
      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Logged In successfully");
        var body = json.decode(response.body);
        print(body);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("userId", body['data']["_id"]);
        preferences.setString("phoneNumber", body['data']['phoneNumber']);
        preferences.setString("username", body['data']['name']);
        preferences.setString("avatar", body['data']['avatar']);
        preferences.setString("message", body['data']['message_template']);

        // List<dynamic> communitiesDynamic = body['data']['communities']?? [];
        List<String> communities = List<String>.from(body['data']['communities'] ?? []);
        print("communities: $communities");
        preferences.setStringList("communities", communities);
        print("after that");

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

  Future<void> signUp(User user, BuildContext context) async {
    String url = "$MAINURL/api/v3/user/signUp";
    try {
      var body = {
        "name": user.name,
        "email": user.email,
        "phoneNumber": user.phoneNumber,
        "password": user.password,
        "confirmPassword": user.confirmPassword,
        "role": "user"
      };

      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        Fluttertoast.showToast(msg: body['message']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpScreen(phoneNumber: user.phoneNumber)));
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print(body);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  Future<void> verifyOtp(
      int otp, String phoneNumber, BuildContext context) async {
    String url = "$MAINURL/api/v3/user/verifyOtp";
    var body = {"otp": otp, "phoneNumber": phoneNumber};
    try {
      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NewLoginPage()));
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print(body);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
    }
  }

  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    String url = "$MAINURL/api/v3/user/resendOtp/$phoneNumber";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
      } else {
        var body = json.decode(response.body);
        Fluttertoast.showToast(msg: body['message']);
        print(body);
      }
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      print("Error $err");
    }
  }
}
