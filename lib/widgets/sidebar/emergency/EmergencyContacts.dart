import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety/api/requestApi.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';
import '../../../api/User.dart';
import 'ContactSelectionPage.dart';
import 'ShowDialogBox.dart';

class EmergencyContacts extends StatefulWidget {
  final String userId;

  const EmergencyContacts({super.key, required this.userId});

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Contact> contacts = [];
  List<Map<String, dynamic>> guardians = [];
  List<Map<String,dynamic>> newGuardians= [];

  List<Contact> emergencyContacts = [];
  Set<Contact> selectedContacts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserGuardians();
  }

  Future<void> fetchContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Iterable<Contact> contactsList = await ContactsService.getContacts();
      setState(() {
        contacts = contactsList.toList();
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final status = await Permission.contacts.request();
      return status;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact permission is denied.'),
        ),
      );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact permission is permanently denied.'),
        ),
      );
    }
  }

  void _navigateToContactSelection() async {
    await fetchContacts();
    final result = await Navigator.push(
        context,
        PageTransition(
            child: ContactSelectionPage(
              contacts: contacts,
              selectedContacts: selectedContacts,
            ),
            type: PageTransitionType.leftToRight,
            duration: Duration(milliseconds: 400)));

    if (result != null) {
      setState(() {
        selectedContacts = result;
        emergencyContacts.addAll(selectedContacts);
        selectedContacts.clear();


        final newContacts = emergencyContacts.map((contact){
          String phoneNumber = contact.phones!.isNotEmpty == true
              ? contact.phones!.first.value?.replaceAll(RegExp(r'[^\d+]'), '') ?? 'No phone number'
              : 'No phone number';

          return {
            'name': contact.displayName ?? 'No Name',
            'phoneNumber': phoneNumber,
          };
        }).toList();

        newGuardians.addAll(newContacts);
        guardians.addAll(newContacts);
        emergencyContacts.clear();
      });

      await _sendNewGuardians();

    }
  }
  Future<void> _sendNewGuardians() async {
    if (newGuardians.isNotEmpty) {
      try {
        print(newGuardians);
        // // Only send new guardians
        // await UserApi().addGuardian(
        //     widget.userId, {'guardian': guardians}, context);

        await RequestApi().createRequest(widget.userId, newGuardians, context);
        newGuardians.clear(); // Clear after successfully updating backend
      } catch (error) {
        print("Error encoding data: $error");
        Fluttertoast.showToast(msg: "Failed to encode data");
      }
    }
  }

  Future<void> _fetchUserGuardians() async {
    try {
      final response = await UserApi().getUser(widget.userId);

      print(response);

      if (response['status'] == 'success') {
        setState(() {
          guardians =
              List<Map<String, dynamic>>.from(response['data']['guardian']);
          isLoading = false;
          print("Guardians :- " + guardians.toString()); // Data loaded
        });
      } else {

        Fluttertoast.showToast(msg: "Failed to fetch guardians");
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching guardians: $error");
      Fluttertoast.showToast(msg: "Error fetching guardians");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmDeleteGuardian(Map<String, dynamic> guardian, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Guardian"),
          content: Text("Are you sure you want to delete ${guardian['name']}?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _deleteGuardian(index); // Call the delete method
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGuardian(int index) {
    setState(() {
      guardians.removeAt(index);
    });

    Fluttertoast.showToast(msg: "Guardian deleted successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Emergency Contacts",
          leadingIcon: Icons.arrow_back,
          backgroundColor: Colors.green.shade900,
          textColor: Colors.white, onPressed: () {
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
      }),
      body: Column(

        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AdvanceButton(
                    onPressed: () async {
                      final newContact = await showAddContactDialog(context,
                          _nameController, _phoneController, widget.userId);
                      if (newContact != null) {
                        setState(() {
                          emergencyContacts.add(newContact);
                        });
                      }
                    },
                    prefixIcon: Icons.add,
                    buttonText: "Add Contacts",
                    backgroundColor: Colors.green.shade900,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: AdvanceButton(
                    onPressed: _navigateToContactSelection,
                    buttonText: "Contacts",
                    prefixIcon: Icons.contacts,
                    backgroundColor: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Loader(context)
                : guardians.isEmpty
                    ? Center(child: noData("No emergency contacts added yet"))
                    : ListView.builder(
                        itemCount: guardians.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map<String, dynamic> guardian = guardians[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.blue.shade100.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(Icons.person,
                                    color: Colors.green.shade900),
                                title: Text(
                                  guardian['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  guardian['phoneNumber'] ?? 'No phone number',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeleteGuardian(guardian, index);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newContact = await showAddContactDialog(
              context, _nameController, _phoneController, widget.userId);
          if (newContact != null) {
            setState(() {
              emergencyContacts.add(newContact);
            });
          }
        },
        backgroundColor: Colors.green[900],
        foregroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
