import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


import '../Pages/otpScreen.dart';
import 'Button/ResuableButton.dart';
import 'TextField/TextField.dart';

void showInputDialogBox(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneText = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dialog dismissal on tap outside
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Apply blur effect
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: SizedBox(
            width: 450, // Increased width
            height: 250, // Increased height
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Text(
                        "Enter Phone Number",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Text field
                      AdvanceTextField(
                        controller: phoneText,
                        label: "Phone Number",
                        type: TextInputType.number,
                        isPasswordField: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Continue button
                      AdvanceButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpScreen(
                                  phoneNumber: phoneText.text,
                                ),
                              ),
                            );
                          }
                        },
                        buttonText: "Continue",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
