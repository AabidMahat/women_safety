import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/api/EmergencyCall.dart';
import 'dart:ui';
import '../LiveLocation/LiveLocation.dart'; // For BackdropFilter

bool isConfirmed = false; // State to track if the user confirmed
// Save the timer so that it can be canceled;
Timer? callTimer;

void startCallScheduler(BuildContext context, String phoneNumber) {
  if (isConfirmed) {
    // Automatically initiate a call every 15 minutes
    callTimer = Timer.periodic(const Duration(minutes: 15), (Timer timer) {
      EmergencyCallApi emergencyCallApi = EmergencyCallApi();
      emergencyCallApi.makeCall(phoneNumber); // Call API to make call
    });
  } else {
    showConfirmationModal(context, phoneNumber);
  }
}

void stopCallScheduler() {
  if (callTimer != null) {
    callTimer!.cancel();
    callTimer = null;
    Fluttertoast.showToast(msg: "Automatic calls are stopped");
  }
}

void showConfirmationModal(BuildContext context, String phoneNumber) {
  EmergencyCallApi emergencyCallApi = EmergencyCallApi();

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5), // Darkens the background
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        // Stronger blur effect for a glass-like background
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Smooth rounded corners
          ),
          elevation: 12,
          // Adds depth with shadow
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          // Slight transparency for a glassy effect
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Confirm Action",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Do you want to initiate a call every 15 minutes?",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Call the API to initiate the first call
                        emergencyCallApi.makeCall(phoneNumber);

                        isConfirmed = true;

                        startCallScheduler(context, phoneNumber);

                        // Close the modal
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                duration: Duration(milliseconds: 400),
                                child: LiveLocation()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
