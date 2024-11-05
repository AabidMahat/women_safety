import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety/api/requestApi.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/TextField/TextField.dart';

import '../../../api/User.dart';
import 'EmergencyContacts.dart';

Future<Contact?> showAddContactDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController phoneController,
    String userId) async {
  Contact? newContact;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        surfaceTintColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero, // Remove extra padding
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Center(
            child: Text(
              'Add Emergency Contact',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 15, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdvanceTextField(
                controller: nameController,
                type: TextInputType.text,
                label: "Name",
                prefixIcon: Icon(Icons.person),
              ),
              AdvanceTextField(
                controller: phoneController,
                type: TextInputType.number,
                label: "Phone Number",
                prefixIcon: Icon(Icons.phone),
              ),
            ],
          ),
        ),
        actions: [
          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AdvanceButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      phoneController.clear();
                    },
                    buttonText: "Cancel",
                    textColor: Colors.red.shade900,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Expanded(
                  child: AdvanceButton(
                    onPressed: () async {
                      newContact = Contact(
                        displayName: nameController.text.trim(),
                        phones: [
                          Item(label: 'mobile', value: phoneController.text.trim())
                        ],
                      );

                      Map<String, dynamic> guardianData = {
                        'name': newContact!.displayName ?? 'No Name',
                        'phoneNumber': newContact!.phones!.first.value!
                            .replaceAll(RegExp(r'[^\d+]'), ''),
                      };

                      try {
                        Map<String, dynamic> updatedData = {
                          'guardian': [guardianData],
                        };

                        List<Map<String,dynamic>> requestData = [];

                        requestData.add(guardianData);

                        await UserApi().addGuardian(userId, updatedData, context);
                        await RequestApi().createRequest(userId, requestData, context);

                        Fluttertoast.showToast(
                          msg: "Contact added successfully",
                          toastLength: Toast.LENGTH_SHORT,
                        );

                        nameController.clear();
                        phoneController.clear();

                        Navigator.of(context).pop(newContact);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmergencyContacts(userId: userId),
                          ),
                        );
                      } catch (error) {
                        print("Error adding contact: $error");
                        Fluttertoast.showToast(msg: "Failed to add contact");
                      }
                    },
                    buttonText: "Add",
                    backgroundColor: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  return newContact;
}
