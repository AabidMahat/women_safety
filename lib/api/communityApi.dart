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

class CommunityApi{

  Future<void> createCommunity(String userId, Map<String, dynamic> communityData) async{
    try{
      final String url = "${MAINURL}/api/v3/community/createCommunity";
      print("userID:: $userId");
      print("community data: $communityData");

      var response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
          },
        body: json.encode({
          "name": communityData["name"],
          "createdBy": communityData["createdBy"],
          "description": communityData["description"],
          "imageUrl": communityData["imageUrl"],
        })
      );

      print("Response status code: ${response.statusCode}");

      if(response.statusCode == 200){
        Fluttertoast.showToast(msg: "Community created successfully");
        print("Community created successfully");
      }
      else{
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: json.decode(response.body)['message'] ?? "Failed to create the community");
      }
    }
    catch(err){
      Fluttertoast.showToast(msg: "failed to created community");
      print("Failed to create community: $err");
    }

  }

  Future<List<Community>> getUserCommunities() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      Fluttertoast.showToast(msg: "User not found.");
      return [];
    }



    try {
      final String url = "${MAINURL}/api/v3/community/getCommunitiesByUser/$userId";
      print("userID:: $userId");

      var response = await http.get(Uri.parse(url));

      print("response status code: ${response.statusCode}");

      if(response.statusCode == 200){
        var body = json.decode(response.body);

        var communitiesData = body["data"];

        print("communities data: $communitiesData");

        List<Community> communities = (communitiesData as List)
            .map((data) => Community.fromJson(data))
            .toList();

        return communities;
      }
      else{
        print("Error response: ${response.body}");

        return [];
      }
    }
    catch(err){
      print("Error fetching communities: $err");
      return [];
    }

  }

}