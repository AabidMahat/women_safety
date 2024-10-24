import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/pages/profile/updatePassword.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/TextField/TextField.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../../Database/Database.dart';
import '../../api/Guardian.dart';

class UpdateProfile extends StatefulWidget {
  final Guardian guardian;

  const UpdateProfile({super.key, required this.guardian});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  // Text Controllers
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  GuardianApi guardianApi = GuardianApi();

  // List of assigned users (for demo purposes)
  List<Map<String, String>> assignedUsers = [];
  List<String> userRemoved = [];
  bool isLoading = false;
  bool isImageStored = false;
  String? avatarUrl;
  PermissionApi permissionApi = PermissionApi();


  @override
  void initState() {
    super.initState();
    getGuardian();
  }

  void getGuardian() {
    setState(() {
      name.text = widget.guardian.name;
      email.text = widget.guardian.email;
      address.text = widget.guardian.address;

      assignedUsers = widget.guardian.userId!.map((child) {
        return {
          'name': child['name'] ?? '',
          'phone': child['phoneNumber'] ?? '',
          'id': child['_id'] ?? ''
        };
      }).toList();
    });
    print("Assigned User $assignedUsers");
  }

  void saveImage() async {
    setState(() {
      isImageStored = true;
    });
    String url = await guardianApi.pickAndUploadImage();
    setState(() {
      avatarUrl = url;
      isImageStored = false;
    });
    print(url);
  }

  void updateGuardian() async {
    try {
      var updateBody = {
        "avatar": avatarUrl,
        "name": name.text,
        "email": email.text,
        "address": address.text,
        "removeUserId": userRemoved,
      };

      setState(() {
        isLoading = true;
      });

      await guardianApi.updateGuardian(updateBody, context);

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Update Profile",
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.green.shade100,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.guardian.avatar == "default.png"
                          ? const AssetImage(
                              "default.png", // Placeholder avatar
                            )
                          : NetworkImage(widget.guardian.avatar)
                              as ImageProvider, // Assuming the avatar is a local asset
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: Colors.white),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          saveImage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Name TextField
            AdvanceTextField(
              controller: name,
              type: TextInputType.text,
              label: "Name",
              prefixIcon: Icon(
                Icons.person,
                color: Colors.green.shade900,
                size: 20,
              ),
            ),
            // Email TextField
            AdvanceTextField(
              controller: email,
              type: TextInputType.emailAddress,
              label: "Email",
              prefixIcon: Icon(
                Icons.email,
                color: Colors.green.shade900,
                size: 20,
              ),
            ),
            // Address TextField
            AdvanceTextField(
              controller: address,
              type: TextInputType.streetAddress,
              label: "Address",
              prefixIcon: Icon(
                Icons.location_on,
                color: Colors.green.shade900,
                size: 20,
              ),
            ),
            // Assigned Users Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assigned Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignedUsers.length,
              itemBuilder: (context, index) {
                String userName = assignedUsers[index]['name'] ?? '';
                String phoneNumber = assignedUsers[index]['phone'] ?? '';
                String id = assignedUsers[index]['id'] ?? '';
                return Dismissible(
                  key: Key(userName + phoneNumber),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.shade900,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      assignedUsers.removeAt(index);
                      userRemoved.add(id);
                    });
                    Fluttertoast.showToast(msg: "${userName} removed");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 2),
                      leading: Icon(Icons.person,
                          color: Colors.green.shade900, size: 22),
                      title: Text(
                        userName,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade900),
                      ),
                      subtitle: Text(
                        phoneNumber,
                        style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: AdvanceButton(
              onPressed: () {
                updateGuardian();
              },
              buttonText: "Save Profile",
              backgroundColor: Colors.green.shade900,
              isLoading: isImageStored,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: AdvanceButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => UpdatePassword()));
              },
              buttonText: "Password",
              backgroundColor: Colors.green.shade900,
            )),
          ],
        ),
      ),
    );
  }
}
