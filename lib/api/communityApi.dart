import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/Database.dart';
import '../consts/AppConts.dart';

class CommunityApi {
  Future<void> createCommunity(String userId, Map<String, dynamic> communityData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("jwtToken");

      final String url = "${MAINURL}/api/v3/community/createCommunity";
      print("userID:: $userId");
      print("community data: $communityData");

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "name": communityData["name"],
          "createdBy": communityData["createdBy"],
          "description": communityData["description"],
          "imageUrl": communityData["imageUrl"],
        }),
      );

      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        String communityId = responseBody['data']['_id'];

        List<String> joinedCommunities = prefs.getStringList("communities") ?? [];
        joinedCommunities.add(communityId);
        await prefs.setStringList("communities", joinedCommunities);

        print("Community created successfully");
      } else {
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: json.decode(response.body)['message'] ?? "Failed to create the community");
      }
    } catch (err) {
      Fluttertoast.showToast(msg: "Failed to create community");
      print("Failed to create community: $err");
    }
  }

  Future<List<Community>> getUserCommunities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("jwtToken");
    String? userId = prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      Fluttertoast.showToast(msg: "User not found.");
      return [];
    }

    try {
      final String url = "${MAINURL}/api/v3/community/getCommunitiesByUser/$userId";
      print("userID:: $userId");

      var response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      print("response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var communitiesData = body["data"];

        print("communities data: $communitiesData");

        List<Community> communities = (communitiesData as List)
            .map((data) => Community.fromJson(data))
            .toList();

        return communities;
      } else {
        print("Error response: ${response.body}");
        return [];
      }
    } catch (err) {
      print("Error fetching communities: $err");
      return [];
    }
  }

  Future<List<Community>> getAllCommunitiesPaginated(int page, int limit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("jwtToken");

      final String url = "${MAINURL}/api/v3/community/getAllCommunitiesPaginated?limit=${limit}&page=${page}";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Community> newCommunities = (data['data'] as List)
            .map((json) => Community.fromJson(json))
            .toList();
        return newCommunities;
      } else {
        print("Error response: ${response.body}");
        return [];
      }
    } catch (err) {
      print("Error fetching communities: $err");
      return [];
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("jwtToken");
    List<String> joinedCommunities = prefs.getStringList("communities") ?? [];
    String userId = prefs.getString("userId") ?? "";

    joinedCommunities.remove(communityId);

    String url = "$MAINURL/api/v3/community/joinCommunity";
    var body = {"userId": userId, "communityId": communityId};

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      var message = json.decode(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: message['message']);
        return true;
      } else {
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: "Error performing this action ${response.body}");
        return false;
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: "Error performing this action $err");
      return false;
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("jwtToken");
    List<String> joinedCommunities = prefs.getStringList("communities") ?? [];
    String userId = prefs.getString("userId") ?? "";

    joinedCommunities.remove(communityId);

    String url = "$MAINURL/api/v3/community/leaveCommunity";
    var body = {"userId": userId, "communityId": communityId};

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      var message = json.decode(response.body);
      if (response.statusCode == 200) {
        print(message['message']);
        Fluttertoast.showToast(msg: message['message']);
        return true;
      } else {
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: "Error performing this action ${response.body}");
        return false;
      }
    } catch (err) {
      print(err);
      Fluttertoast.showToast(msg: "Error performing this action $err");
      return false;
    }
  }
}
