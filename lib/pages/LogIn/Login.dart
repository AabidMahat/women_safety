
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:women_safety/home_screen.dart';
import '../../api/Firebase_api.dart';
import '../../api/loginApi.dart';
import '../../firebase_options.dart';
import '../../widgets/Button/ResuableButton.dart';
import '../../widgets/TextField/TextField.dart';
import '../../widgets/modalWindow.dart';
import '../SignUp/Register.dart';


final navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotification();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    home: NewLoginPage(),
    routes: {
      "/home":(context)=>HomeScreen()
    },
  ));
}

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({Key? key}) : super(key: key);

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  var phoneText = TextEditingController();
  var passText = TextEditingController();

  LoginApi loginApi = LoginApi();

  bool _isPasswordVisible = false;
  var userId;
  bool isLoading = false;
  List staffAccount = [];

  @override
  void initState() {
    super.initState();
    // removePrefs();
  }
  void login() async {
    try {
      setState(() {
        isLoading = true;
      });
      await loginApi.login(phoneText.text, passText.text, context);

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 32),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "assets/womenSafety.jpg",
                              color: Colors.transparent,
                              colorBlendMode: BlendMode.multiply,
                              width: 241,
                              height: 169,
                              fit: BoxFit.cover,
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
                                color: Color(0xFF101213),
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            AdvanceTextField(
                              controller: phoneText,
                              type: TextInputType.number,
                              label: "Phone",
                              isPasswordField: false,
                            ),
                            AdvanceTextField(
                              controller: passText,
                              type: TextInputType.text,
                              label: "Password",
                              isPasswordField: true,
                              isObscuredInitially: !_isPasswordVisible,
                            ),
                            AdvanceButton(
                              isLoading: isLoading,
                              // Pass the loading state variable
                              onPressed: () {
                                login();
                              },
                              // Function to execute on press
                              buttonText: 'Login',
                              // The text to display on the button
                              backgroundColor: Colors
                                  .green.shade900, // Optional: button color
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             ResetPassword()));
                                    },
                                    child: Text(
                                      'Forget password',
                                      style: TextStyle(
                                        color: Color(0xFF57636C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: TextButton(
                                    onPressed: () {
                                      showInputDialogBox(context);
                                    },
                                    child: Text(
                                      'Resend Otp',
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account?  ",
                                        style: TextStyle(
                                          color: Color(0xFF101213),
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign Up here',
                                        style: TextStyle(
                                          color: Color(0xFF4B39EF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
