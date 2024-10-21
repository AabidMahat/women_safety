import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../../widgets/TextField/TextField.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Change Password",
        backgroundColor: Colors.green.shade900,
        onPressed: () {},
        textColor: Colors.white,
        leadingIcon: Icons.menu,
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            AdvanceTextField(
              controller: password,
              type: TextInputType.text,
              label: "Password",
              isPasswordField: true,
              prefixIcon: Icon(Icons.lock_clock_outlined),
            ),
            AdvanceTextField(
                controller: confirmPassword,
                type: TextInputType.text,
                label: "Confirm Password",
                isPasswordField: true,
                prefixIcon: Icon(Icons.lock_clock_outlined))
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: AdvanceButton(
          onPressed: () {},
          buttonText: "Update Password",
          backgroundColor: Colors.green.shade900,
        ),
      ),
    );
  }
}
