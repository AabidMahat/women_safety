import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:path/path.dart' as path;

class CreateCommunityScreen extends StatefulWidget {
  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  final communityApi = CommunityApi();
  bool isLoading = false;

  Future<void> createCommunity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User ID not found")));
      return;
    }

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and upload an image")));
      return;
    }

    try {
      setState(() => isLoading = true);

      final Map<String, dynamic> communityData = {
        "name": _nameController.text.trim(),
        "createdBy": userId,
        "description": _descriptionController.text.trim(),
        "imageUrl": _imageUrl,
      };

      await communityApi.createCommunity(userId, communityData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Community Created Successfully")));

      // Optional: Clear form
      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
        _imageUrl = null;
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        PageTransition(
          child: HomeScreen(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 400),
        ),
      );
    } catch (err) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${err.toString()}")));
    }
  }

  Future<void> pickImage() async {
    print("picking the image");
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await uploadImageToFirebase();
    }
  }

  Future<void> uploadImageToFirebase() async {
    try {
      if (_imageFile == null) return;

      final fileName = path.basename(_imageFile!.path);
      final storageRef = FirebaseStorage.instance.ref().child('community_images/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("image url: $downloadUrl");
      setState(() => _imageUrl = downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload failed: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Create Community",
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                      : Center(child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40)),
                ),
              ),
              SizedBox(height: 20),
              Text("Community Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter community name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 20),
              Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter community description",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: createCommunity,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green.shade900,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Create Community", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
