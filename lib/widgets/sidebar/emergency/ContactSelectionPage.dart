import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/widgets/customAppBar.dart';

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

class _ContactSelectionPageState extends State<ContactSelectionPage>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  List<Contact> filteredContacts = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts; // Initialize with full contact list
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts =
            widget.contacts; // Show all contacts if search is empty
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
      appBar: customAppBar("Contacts",
          leadingIcon: Icons.arrow_back,
          backgroundColor: Colors.green.shade900,
          textColor: Colors.white, onPressed: () {
        Navigator.pop(
            context,
            PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
      }),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _filterContacts,
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      Contact contact = filteredContacts[index];
                      bool isSelected =
                          widget.selectedContacts.contains(contact);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              widget.selectedContacts.remove(contact);
                            } else {
                              widget.selectedContacts.add(contact);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                contact.displayName != null &&
                                        contact.displayName!.isNotEmpty
                                    ? contact.displayName![0].toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName ?? 'No Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            subtitle: contact.phones!.isNotEmpty
                                ? Text(
                                    contact.phones!.first.value!,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[700]),
                                  )
                                : Text(
                                    'No phone number',
                                    style: TextStyle(color: Colors.red),
                                  ),
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected ? Colors.green : Colors.grey,
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            _animationController.forward().then((_) {
              Navigator.pop(context, widget.selectedContacts);
            });
          },
          child: Icon(Icons.done, color: Colors.white, size: 28),
          backgroundColor: Colors.blue[900],
          elevation: 10,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
