import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/api/User.dart';
import 'package:women_safety/pages/profile/profile.dart';
import 'package:women_safety/pages/profile/updatePassword.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/TextField/TextField.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../../Database/Database.dart';
import '../../api/Guardian.dart';

class UpdateProfile extends StatefulWidget {
  final UserData user;

  const UpdateProfile({super.key, required this.user});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  // Text Controllers
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  GuardianApi guardianApi = GuardianApi();

  // List of assigned users (for demo purposes)
  List<Map<String, String>> assignedGuardians = [];
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
      avatarUrl = widget.user.avatar;
      name.text = widget.user.name;
      email.text = widget.user.email;

      assignedGuardians =
          widget.user.guardians.map<Map<String, String>>((guardian) {
        return {
          "name": guardian["name"] ?? '',
          "phoneNumber": guardian["phoneNumber"] ?? '',
          "id": guardian["_id"] ?? '',
        };
      }).toList();
    });
  }

  void saveImage() async {
    setState(() {
      isImageStored = true;
    });
    String url = await UserApi().pickAndUploadImage();
    setState(() {
      avatarUrl = url;
      isImageStored = false;
    });
    print(url);
  }

  void updateUser() async {
    try {
      var updateBody = {
        "avatar": avatarUrl,
        "name": name.text,
        "email": email.text,
        "guardian":assignedGuardians
      };

      setState(() {
        isLoading = true;
      });

      await UserApi().updateUser(updateBody, context);

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
      appBar: customAppBar("Update Profile",
          backgroundColor: Colors.green.shade900,
          textColor: Colors.white,
          leadingIcon: Icons.arrow_back, onPressed: () {
        Navigator.pop(
            context,
            PageTransition(
                child: ProfilePage(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
      }),
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
                      backgroundImage: widget.user.avatar == "default.png"
                          ? const AssetImage(
                              "default.png", // Placeholder avatar
                            )
                          : NetworkImage(widget.user.avatar)
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
            // Assigned Users Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Guardian Assigned',
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
              itemCount: assignedGuardians.length,
              itemBuilder: (context, index) {
                String userName = assignedGuardians[index]['name'] ?? '';
                String phoneNumber = assignedGuardians[index]['phoneNumber'] ?? '';
                String id = assignedGuardians[index]['id'] ?? '';
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
                      assignedGuardians.removeAt(index);
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
                          color: Colors.green.shade900, size: 24),
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
                            fontSize: 14),
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
            SizedBox(
              height: 65,
                width: MediaQuery.of(context).size.width/2,
                child: AdvanceButton(
              onPressed: () {
                updateUser();
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
