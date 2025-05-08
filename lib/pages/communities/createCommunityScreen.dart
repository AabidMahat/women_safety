import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/TextField/TestArea.dart';
import 'package:women_safety/widgets/TextField/TextField.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User ID not found")));
      return;
    }

    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill all fields and upload an image")));
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

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Community Created Successfully")));

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${err.toString()}")));
    }
  }

  Future<void> pickImage() async {
    print("picking the image");
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await uploadImageToFirebase();
    }
  }

  Future<void> uploadImageToFirebase() async {
    try {
      if (_imageFile == null) return;

      final fileName = path.basename(_imageFile!.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('community_images/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print("image url: $downloadUrl");
      setState(() => _imageUrl = downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed: ${e.toString()}")));
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
                    color: Colors.grey.shade100, // Light background color for empty state
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              AdvanceTextField(
                  controller: _nameController,
                  type: TextInputType.text,
                  label: 'Community Name'),



              AdvanceTextArea(controller: _descriptionController, label: "Community Description"),

              isLoading
                  ? Loader(context)
                  : SizedBox(
                      width: double.infinity,
                      child: AdvanceButton(
                        onPressed: createCommunity,
                        buttonText: "Create Community",
                        backgroundColor: Colors.green.shade900,

                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
