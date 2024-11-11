import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/TextField/TestArea.dart';
import 'package:women_safety/widgets/customAppBar.dart';

class MessageTemplate extends StatefulWidget {
  const MessageTemplate({super.key});

  @override
  State<MessageTemplate> createState() => _MessageTemplateState();
}

class _MessageTemplateState extends State<MessageTemplate> {
  TextEditingController message = TextEditingController();

  @override
  void initState() {
    setData();
    super.initState();
  }

  void setData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? messageTemplate = preferences.getString("message");
    setState(() {
      message.text = messageTemplate ?? "I'm in trouble";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Template",
          backgroundColor: Colors.green.shade900,
          leadingIcon: Icons.arrow_back, onPressed: () {
        Navigator.push(
            context,
            PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
      }),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: AdvanceTextArea(controller: message, label: "Message"),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 70,
        child: AdvanceButton(
          onPressed: () {},
          buttonText: "Update",
          backgroundColor: Colors.green.shade900,
        ),
      ),
    );
  }
}
