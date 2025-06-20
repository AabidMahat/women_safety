import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Needed for JWT
import 'package:women_safety/Database/Database.dart';
import '../consts/AppConts.dart';

class PostApi {

  Future<void> createPost(String userId, Map<String, dynamic> postData) async {
    try {
      final String url = "$MAINURL/api/v3/post/createPost";
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("jwtToken");

      print("userID:: $userId");
      print("community data: $postData");

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "title": postData["title"],
          "createdBy": postData["createdBy"],
          "description": postData["description"],
          "communityId": postData["communityId"],
          "images": postData["images"] ?? [],
        }),
      ).timeout(Duration(seconds: 10));

      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Post created successfully");
        print("Post created successfully");
      } else {
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: json.decode(response.body)['message'] ?? "Failed to create the post");
      }
    } catch (err) {
      Fluttertoast.showToast(msg: "failed to create post");
      print("Failed to create post: $err");
    }
  }

  Future<List<Post>> getCommunityPostsPaginated(int page, int limit, String communityId) async {
    try {
      final String url = "$MAINURL/api/v3/post/getCommunityPosts/$communityId?limit=$limit&page=$page";
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("jwtToken");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: ${data['posts']}");
        List<Post> posts = (data['posts'] as List)
            .map((json) => Post.fromJson(json))
            .toList();
        return posts;
      } else {
        print("Error response: ${response.body}");
        return [];
      }
    } catch (err) {
      print("Error fetching posts: $err");
      return [];
    }
  }

  Future<void> makeComment(String userId, Map<String, dynamic> commentData) async {
    try {
      final String url = "$MAINURL/api/v3/post/addCommentToPost";
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("jwtToken");

      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "userName": commentData["userName"],
          "comment": commentData["comment"],
          "postId": commentData["postId"],
          "userImage": commentData["userImage"],
          "userId": userId,
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "comment has been made successfully");
        print("comment has been made successfully");
      } else {
        print("Error response: ${response.body}");
        Fluttertoast.showToast(msg: json.decode(response.body)['message'] ?? "Failed to make the comment");
      }
    } catch (err) {
      Fluttertoast.showToast(msg: "failed to make the comment");
      print("Failed to make the comment: $err");
    }
  }

  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 10}) async {
    try {
      final url = Uri.parse("$MAINURL/api/v3/post/getPostComments/$postId?page=$page&limit=$limit");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString("jwtToken");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");

        List<Comment> comments = (data['data'] as List)
            .map((json) => Comment.fromJson(json))
            .toList();

        return comments;
      } else {
        print("Error response: ${response.body}");
        return [];
      }
    } catch (err) {
      print("Error fetching comments: $err");
      return [];
    }
  }
}
