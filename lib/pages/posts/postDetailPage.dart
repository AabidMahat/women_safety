import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/postsApi.dart';



class PostDetailsPage extends StatefulWidget {
  final Post post;
  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final postsApi = PostApi();
  List<Comment> comments = [];
  bool isLoading = true;

  int currentPage = 1;
  final int limit = 10;
  bool hasMoreComments = true;
  final ScrollController _commentScrollController = ScrollController();

  final TextEditingController _commentController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchComments();

    _commentScrollController.addListener(() {
      if (_commentScrollController.position.pixels >= _commentScrollController.position.maxScrollExtent - 100) {
        fetchComments();
      }
    });
  }

  void fetchComments() async {
    if (!hasMoreComments) return;

    final newComments = await postsApi.getComments(widget.post.id, page: currentPage, limit: limit);

    setState(() {
      comments.addAll(newComments);
      isLoading = false;
      if (newComments.length < limit) {
        hasMoreComments = false;
      } else {
        currentPage++;
      }
    });
  }

  void submitComment() async {
    if (_commentController.text.trim().isEmpty || isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId") ?? "";
    final userName = prefs.getString("username") ?? "User";
    final userImage = prefs.getString("avatar") ?? "https://via.placeholder.com/150";

    final commentText = _commentController.text.trim();

    await postsApi.makeComment(userId, {
      "userName": userName,
      "comment": commentText,
      "postId": widget.post.id,
      "userImage": userImage,
    });

    _commentController.clear();

    setState(() {
      comments.insert(0, Comment(
        comment: commentText,
        userName: userName,
        userImage: userImage, createdAt: DateTime.now(),
      ));
      isSubmitting = false;
    });
  }


  @override
  void dispose() {
    _commentScrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(post.description, style: const TextStyle(fontSize: 16)),
                  const Divider(height: 32),
                  const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      controller: _commentScrollController,
                      itemCount: comments.length + 1,
                      itemBuilder: (context, index) {
                        if (index < comments.length) {
                          final comment = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment.userImage == "default.png" ?
                              NetworkImage("https://cdn.pixabay.com/photo/2012/04/26/19/43/profile-42914_1280.png") as ImageProvider
                                  : NetworkImage(comment.userImage) as ImageProvider
                            ),
                            title: Text(comment.userName),
                            subtitle: Text(comment.comment),
                          );
                        } else if (hasMoreComments) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment input field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSubmitting
                    ? const CircularProgressIndicator()
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
