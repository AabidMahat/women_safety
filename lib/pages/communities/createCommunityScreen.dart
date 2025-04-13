
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/widgets/customAppBar.dart';

class CreateCommunityScreen extends StatefulWidget{
  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen>{

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();


  final communityApi = CommunityApi();
  bool isLoading = false;

  void createCommunity() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId= prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User ID not found")));
      return;
    }

    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    String usersId = userId;

    try{
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> communityData = {
        "name": _nameController.text.trim(),
        "createdBy": usersId,
        "description": _descriptionController.text.trim(),
        "imageUrl": _imageUrlController.text.trim(),
      };

      await communityApi.createCommunity(usersId, communityData);

      setState(() {
        isLoading = false;
      });
    }
    catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Create Community",
        onPressed: (){
          Navigator.pop(
              context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: Duration(microseconds: 400)
            )
          );
        },
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Community Name"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: "Image URL"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: createCommunity,
              child: Text("Create Community"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900),
            )
          ],
        ),
      ),
    );

  }


}