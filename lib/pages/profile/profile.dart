import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/Guardian.dart';
import 'package:women_safety/pages/childrensAssigned.dart';
import 'package:women_safety/pages/profile/updateProfile.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/cards/cards.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Guardian? guardian;
  GuardianApi guardianApi = GuardianApi();

  @override
  void initState() {
    getGuardian();
    super.initState();
  }

  void getGuardian() async {
    Guardian? data = await guardianApi.getGuardian();

    setState(() {
      guardian = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: guardian == null
          ? Center(
              // Center the CircularProgressIndicator properly
              child: SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height, // Ensures proper centering
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade900,
                              Colors.green.shade700
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade900.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1624561172888-ac93c696e10c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NjJ8fHVzZXJzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60', // Placeholder avatar
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              guardian!.name,
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54, // Shadow color
                                    blurRadius: 2, // Shadow blur
                                    offset: Offset(2, 2), // Shadow offset
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Phone Number Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AdvancedCard(
                      cardTitle: "Phone Number",
                      cardInfo: guardian!.phoneNumber,
                      cardIcons: Icons.phone,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AdvancedCard(
                      cardTitle: "Email",
                      cardInfo: guardian!.email,
                      cardIcons: Icons.email,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AdvancedCard(
                      cardTitle: "Address",
                      cardInfo: "123 Example Street", // Placeholder address
                      cardIcons: Icons.location_on,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildrenAssigned(
                                children: guardian!.userId
                                    ?.map((child) => {
                                          'id': child['_id'] ?? '',
                                          'name': child['name'] ?? '',
                                          'phone': child['phoneNumber'] ?? '',
                                        })
                                    .toList(),
                              ),
                            ));
                      },
                      child: AdvancedCard(
                        cardTitle: "Childrens",
                        cardInfo: "Tap to view", // Placeholder address
                        cardIcons: Icons.family_restroom,
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // Move bottomNavigationBar out of the body
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // This will allow the row to take only the space it needs
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: AdvanceButton(
                prefixIcon: Icons.delete,
                onPressed: () {
                  // Add delete functionality here
                },
                buttonText: "Delete",
                backgroundColor: Colors.red.shade900,
              ),
            ),
            const SizedBox(width: 10), // Add space between the buttons
            Expanded(
              child: AdvanceButton(
                prefixIcon: Icons.edit,
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfile(
                                guardian: guardian!,
                              )));
                },
                buttonText: "Edit",
                backgroundColor: Colors.green.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
