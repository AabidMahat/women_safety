import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:women_safety/consts/AppConts.dart';

class TokenApi {
  Future<void> addOrUpdateFCMToken(String userId, String fcmToken) async {
    try {
      final String url = "${MAINURL}/api/v3/token/addToken";
      var body = {"userId": userId, "fcm_token": fcmToken};

      final response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        print("Token Added successfully");
      } else {
        String errMsg = json.decode(response.body);
        print("Error : ${errMsg}");
      }
    } catch (err) {
      print("Error occured $err");
    }
  }

  Future<List<String>> getAllTokens(List<String> userId) async {
    try {

      print(userId);

      final String url = "${MAINURL}/api/v3/token/getAllToken";

      var body = {"userId": userId};

      final response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<String> tokens = List<String>.from(
          data['data'].map((user) => user['fcm_token'] as String),
        );

        return tokens;
      } else {
        return [];
      }
    } catch (err) {
      print("Error while getting token $err");
      return [];
    }
  }

  Future<String> getTokenByPhoneNumber(String phoneNumber) async {
    try {
      String fcm_token = "";
      String url = "${MAINURL}/api/v3/token/getTokenOnNumber";

      if (phoneNumber.startsWith("+91")) {
        phoneNumber = phoneNumber.replaceFirst("+91", "");
      }

      var body = {"phoneNumber": phoneNumber};

      var response = await http.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      if(response.statusCode==200){
        var data =  json.decode(response.body);

        print(data['data']['fcm_token']);

        fcm_token = data['data']['fcm_token'];

        return fcm_token;
      }
      else{
        return fcm_token;
      }
    } catch (err) {
      print("Error while getting token $err");
      return "";
    }
  }

}
