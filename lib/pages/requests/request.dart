import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/Guardian.dart';
import 'package:women_safety/api/User.dart';
import 'package:women_safety/api/requestApi.dart';
import 'package:women_safety/pages/profile/profile.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage>
    with SingleTickerProviderStateMixin {
  List<UserAssignedGuardian> users = [];
  List<Map<String, String>> userData = [];
  List<UserAssignedGuardian> acceptedUser = [];
  bool isLoading = false;
  bool isUpdating = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    getUserRequest();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0.25, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void getUserRequest() async {
    setState(() {
      isLoading = true;
    });
    List<UserAssignedGuardian> assignedUsers =
    await RequestApi().getGuardianByUserId();
    setState(() {
      users = assignedUsers;

      userData = users
          .map((user) => {
        "phoneNumber": user.phoneNumber,
        "status": user.status,
        "name": user.name
      })
          .toList();

      isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void approveAction(int index, String userId) {
    setState(() {
      int userDataIndex =
      userData.indexWhere((data) => data["userId"] == userId);
      userData[userDataIndex]['status'] = "approved";

      acceptedUser.add(users[userDataIndex]);

      users.removeAt(index);
    });

    Fluttertoast.showToast(msg: "Request Approved");
  }

  void declineAction(int index, String userId) {
    setState(() {
      int userDataIndex =
      userData.indexWhere((data) => data["userId"] == userId);
      userData[userDataIndex]['status'] = "declined";
      users.removeAt(index);
    });

    Fluttertoast.showToast(msg: "Request Declined");
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade100;
      case 'declined':
        return Colors.red.shade100;
      case 'pending':
      default:
        return Colors.yellow.shade100;
    }
  }

  Widget getStatusBadge(String status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case 'approved':
        badgeColor = Colors.green.shade900;
        statusText = 'Approved';
        break;
      case 'declined':
        badgeColor = Colors.red.shade900;
        statusText = 'Declined';
        break;
      case 'pending':
      default:
        badgeColor = Colors.orange.shade900;
        statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Request Page",
        leadingIcon: Icons.arrow_back,
        backgroundColor: Colors.green.shade900,
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: ProfilePage(),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 400),
            ),
          );
        },
        textColor: Colors.white,
      ),
      body: isLoading
          ? Loader(context)
          : users.isEmpty
          ? noData("No Request available")
          : Container(
        margin: const EdgeInsets.only(top: 20),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Dismissible(
                key: Key(user.phoneNumber),
                background: Container(
                  color: Colors.green.shade900,
                  alignment: Alignment.centerLeft,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red.shade900,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.cancel_outlined, color: Colors.white, size: 30),
                  ),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    // approveAction(index, user.id);
                  } else if (direction == DismissDirection.endToStart) {
                    // declineAction(index, user.id);
                  }
                },
                child: Container(
              decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5), // blue shadow color
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey.shade600, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              user.phoneNumber,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        getStatusBadge(user.status),
                      ],
                    ),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ),
            );

          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: AdvanceButton(
          onPressed: () {
            // updateList();
          },
          isLoading: isUpdating,
          buttonText: 'Save',
          backgroundColor: Colors.green.shade900,
          prefixIcon: Icons.check,
        ),
      ),
    );
  }
}
