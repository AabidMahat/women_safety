import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactSelectionPage extends StatefulWidget {
  final List<Contact> contacts;
  final Set<Contact> selectedContacts;

  const ContactSelectionPage({
    super.key,
    required this.contacts,
    required this.selectedContacts,
  });

  @override
  State<ContactSelectionPage> createState() => _ContactSelectionPageState();
}

class _ContactSelectionPageState extends State<ContactSelectionPage> {
  TextEditingController searchController = TextEditingController();
  List<Contact> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts; // Initialize with full contact list
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = widget.contacts; // Show all contacts if search is empty
      } else {
        filteredContacts = widget.contacts.where((contact) {
          String contactName = contact.displayName?.toLowerCase() ?? '';
          return contactName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Contacts",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[900],

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: _filterContacts,
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(child: Text('No contacts found.'))
                : ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = filteredContacts[index];
                bool isSelected = widget.selectedContacts.contains(contact);
                return Container(
                  color: isSelected
                      ? Colors.green
                      : Colors.transparent,
                  child: ListTile(
                    title: Text(contact.displayName ?? 'No Name'),
                    subtitle: contact.phones!.isNotEmpty
                        ? Text(contact.phones!.first.value!)
                        : Text('No phone number'),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            widget.selectedContacts.add(contact);
                          } else {
                            widget.selectedContacts.remove(contact);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, widget.selectedContacts); // Return selected contacts
        },
        child: Icon(Icons.done,color: Colors.white,),
        backgroundColor: Colors.blue[900],
      ),
    );
  }
}
