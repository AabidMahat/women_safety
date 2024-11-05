import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/pages/profile/profile.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';

import '../Database/Database.dart';
import '../api/requestApi.dart';
import '../widgets/cards/cards.dart';

class ChildrenAssigned extends StatefulWidget {
  const ChildrenAssigned({super.key});

  @override
  State<ChildrenAssigned> createState() => _ChildrenAssignedState();
}

class _ChildrenAssignedState extends State<ChildrenAssigned> {
  List<Map<String, String>> approvedGuardians = [];
  bool isLoading = false;

  @override
  void initState() {
    getUserRequest();
    super.initState();
  }

  void getUserRequest() async {
    setState(() {
      isLoading = true;
    });

    // Fetch all user requests
    List<UserAssignedGuardian> assignedUsers = await RequestApi().getGuardianByUserId();

    // Filter approved guardians only
    setState(() {
      approvedGuardians = assignedUsers
          .where((user) => user.status == "approved") // Filter by status
          .map((user) => {
        "phoneNumber": user.phoneNumber,
        "status": user.status,
        "name": user.name,
      })
          .toList();

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Guardian Assigned",
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
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
      ),
      body: isLoading
          ? Loader(context)
          : approvedGuardians.isEmpty
          ? noData("No approved guardians available.")
          : ListView.builder(
        itemCount: approvedGuardians.length,
        itemBuilder: (context, index) {
          var guardian = approvedGuardians[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: AdvancedCard(
              cardTitle: guardian['name']!,
              cardInfo: guardian['phoneNumber']!,
              cardIcons: Icons.person,
            ),
          );
        },
      ),
    );
  }
}
