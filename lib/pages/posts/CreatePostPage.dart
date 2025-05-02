import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:women_safety/api/postsApi.dart';
import 'package:path/path.dart' as path;

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
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  void _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages = picked;
      });
    }
  }

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

    List<String> imageUrls = [];
    for (XFile image in _selectedImages) {
      // Assume uploadImage returns a hosted image URL (e.g., Firebase/Cloudinary)
      String? imageUrl = await uploadImageToFirebase(File(image.path));
      if(imageUrl == null) continue;
      imageUrls.add(imageUrl);
    }

    final postData = {
      "title": title,
      "description": description,
      "createdBy": widget.userId,
      "communityId": widget.communityId,
      "images": imageUrls,
    };

    await PostApi().createPost(widget.userId, postData);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  Future<String?> uploadImageToFirebase(File image_file) async {
    try {

      final fileName = path.basename(image_file.path);
      final storageRef = FirebaseStorage.instance.ref().child('community_images/$fileName');
      final uploadTask = storageRef.putFile(image_file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("image url: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed: ${e.toString()}")));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
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
            const SizedBox(height: 16),

            /// Pick Images Button
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.photo_library),
              label: Text("Select Images"),
            ),

            const SizedBox(height: 16),

            /// Image Carousel
            if (_selectedImages.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
                items: _selectedImages.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      );
                    },
                  );
                }).toList(),
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
