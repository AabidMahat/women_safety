import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../Database/Database.dart';
import '../../api/loginApi.dart';
import '../../consts/AppConts.dart';
import '../../widgets/Button/ResuableButton.dart';
import '../../widgets/TextField/TextField.dart';
import '../LogIn/Login.dart';

void main() {
  runApp(MaterialApp(
    home: Register(),
    debugShowCheckedModeBanner: false,
  ));
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>(); // Create a GlobalKey for the form
  var fullNameText = TextEditingController();
  var emailText = TextEditingController();
  var phoneText = TextEditingController();
  var passText = TextEditingController();
  var confirmPassText = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isLoading = false;
  var userId;
  List staffAccount = [];

  LoginApi loginApi = LoginApi();

  void createAccount() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String url = "${MAINURL}/api/v3/user/signUp";
      User userBody = User(
          role: "gurdian",
          name: fullNameText.text,
          email: emailText.text,
          phoneNumber: phoneText.text,
          password: passText.text,
          confirmPassword: confirmPassText.text);
      await loginApi.signUp(userBody, context);

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              // Wrap form fields in a Form widget
              key: _formKey, // Assign the GlobalKey to the form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              "assets/secondary-logo.jpeg",
                              width: 241,
                              height: 169,
                            ),
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 570,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: Color(0xFF101213),
                                fontSize: 36,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
                              child: Text(
                                'Fill out the information below to create your account.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF57636C),
                                  fontSize: 14,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Full Name Field
                            AdvanceTextField(
                                controller: fullNameText,
                                type: TextInputType.text,
                                label: 'Full Name'),
                            // Email Field
                            AdvanceTextField(
                              controller: emailText,
                              type: TextInputType.emailAddress,
                              label: 'Email',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                String pattern =
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            AdvanceTextField(
                              controller: phoneText,
                              type: TextInputType.phone,
                              label: 'Phone Number',
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

                            AdvanceTextField(
                              controller: passText,
                              type: TextInputType.text,
                              label: 'Password',
                              isPasswordField: true,
                              isObscuredInitially: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length <= 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                                return null;
                              },
                            ),

                            // Password Field
                            AdvanceTextField(
                              controller: confirmPassText,
                              type: TextInputType.text,
                              label: 'Confirm Password',
                              isPasswordField: true,
                              isObscuredInitially: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != passText.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            AdvanceButton(
                                backgroundColor: Colors.green.shade900,
                                isLoading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          createAccount();
                                        }
                                      },
                                buttonText: 'Create Account'),
                            // Submit Button

                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          duration: Duration(milliseconds: 500),
                                          type: PageTransitionType.rightToLeft,
                                          child: NewLoginPage()));
                                },
                                child: Text(
                                  'Already have an account? Login here',
                                  style: TextStyle(
                                    color: Color(0xFF4B39EF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
