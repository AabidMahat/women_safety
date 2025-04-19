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
      if (_commentScrollController.position.pixels >=
          _commentScrollController.position.maxScrollExtent - 100) {
        fetchComments();
      }
    });
  }

  void fetchComments() async {
    if (!hasMoreComments) return;
    final newComments = await postsApi.getComments(widget.post.id,
        page: currentPage, limit: limit);
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
    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId") ?? "";
    final userName = prefs.getString("username") ?? "User";
    final userImage = prefs.getString("avatar") ??
        "https://cdn.pixabay.com/photo/2012/04/26/19/43/profile-42914_1280.png";
    final commentText = _commentController.text.trim();

    await postsApi.makeComment(userId, {
      "userName": userName,
      "comment": commentText,
      "postId": widget.post.id,
      "userImage": userImage,
    });

    _commentController.clear();
    setState(() {
      comments.insert(
        0,
        Comment(
          comment: commentText,
          userName: userName,
          userImage: userImage,
          createdAt: DateTime.now(),
        ),
      );
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
      appBar: AppBar(
        title: const Text("Post Details"),
        backgroundColor: Colors.green.shade800,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _commentScrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Post Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          post.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Comments Header
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Comments List
                if (comments.isEmpty && !isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        "No comments yet. Be the first!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ...comments.map((comment) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: comment.userImage == "default.png"
                          ? const NetworkImage(
                          "https://cdn.pixabay.com/photo/2012/04/26/19/43/profile-42914_1280.png")
                          : NetworkImage(comment.userImage),
                    ),
                    title: Text(comment.userName,
                        style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(comment.comment),
                  ),
                )),
                if (hasMoreComments && isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),

          // Comment Input
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        const BorderSide(color: Colors.grey, width: 0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
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
