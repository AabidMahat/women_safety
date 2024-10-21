import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ContactSelectionPage.dart';


class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({super.key});

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Contact> contacts = [];
  List<Contact> emergencyContacts = []; // List to store emergency contacts
  Set<Contact> selectedContacts = {}; // Set to track selected contacts

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchContacts() async {
    // Request contact permission
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // Fetch contacts
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contact permission is denied.'),
      ));
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contact permission is permanently denied.'),
      ));
    }
  }

  void _navigateToContactSelection() async {
    // Fetch contacts before navigating
    await fetchContacts();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactSelectionPage(
          contacts: contacts,
          selectedContacts: selectedContacts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedContacts = result; // Update selected contacts
        emergencyContacts.addAll(selectedContacts); // Add to emergency contacts
        selectedContacts.clear(); // Clear after adding
      });
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text('Add Emergency Contact',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Contact Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _nameController.clear();
                _phoneController.clear();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                Contact newContact = Contact(
                  displayName: _nameController.text.trim(),
                  phones: [
                    Item(label: 'mobile', value: _phoneController.text.trim())
                  ],
                );

                setState(() {
                  emergencyContacts.add(newContact);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Emergency Contacts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _showAddContactDialog,
                  child: Text("Add Emergency Contact"),
                ),
                TextButton(
                  onPressed: _navigateToContactSelection,
                  child: Text("Add from Contacts"),
                ),
              ],
            ),
          ),
          // Display selected Emergency Contacts
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: emergencyContacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = emergencyContacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? 'No Name'),
                  subtitle: contact.phones!.isNotEmpty
                      ? Text(contact.phones!.first.value!)
                      : Text('No phone number'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
