import 'package:flutter/material.dart';
import 'package:women_safety/api/postsApi.dart';

class CreatePostPage extends StatefulWidget {
  final String userId;
  final String communityId;

  const CreatePostPage({super.key, required this.userId, required this.communityId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _submitPost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Title and Description cannot be empty")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final postData = {
      "title": title,
      "description": description,
      "createdBy": widget.userId,
      "communityId": widget.communityId,
    };

    await PostApi().createPost(widget.userId, postData);

    setState(() => _isLoading = false);

    // Navigate back or clear form
    Navigator.pop(context); // or use reset fields if staying on page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Post"),
            ),
          ],
        ),
      ),
    );
  }
}
