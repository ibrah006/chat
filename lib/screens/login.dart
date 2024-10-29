

import 'package:chat/components/static/login_main.dart';
import 'package:chat/components/static/set_display_name.dart';
import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends MainWrapperStateful {
  LoginScreen(this.currentDeviceFcmToken);

  final String currentDeviceFcmToken;

  static const Iterable _quickLogins = [
    "ibrah@chatly.com",
    "dell@chatly.com",
    "flutteremu@chatly.com",
    "samsung@chatly.com"
  ];


  final emailController = TextEditingController(), passController = TextEditingController(), displayNameController = TextEditingController(), confirmPassController = TextEditingController();

  final auth = FirebaseAuth.instance;

  bool showDisplayNameInput = false;

  bool isLogin = true;

  void login() async {
    if (!emailController.text.isEmail && passController.text.trim().isEmpty) {
      // TODO: show erro feedback to user
      return;
    }

    await auth.signInWithEmailAndPassword(email: emailController.text, password: passController.text);

    authenticationCheck(isLogin: true);
  }

  void checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 1));
    if (auth.currentUser != null) {
      authenticationCheck();
    }
  }

  String selectedQuickLogin = _quickLogins.elementAt(0);

  void updateFields() {
    emailController.text = selectedQuickLogin;
    passController.text = "12345678";
  }

  void authenticationCheck({bool isLogin = false}) {
    // run this function whether sign in/up

    if (auth.currentUser!.displayName == null || auth.currentUser!.displayName!.isEmpty) {
      setState(() {
        showDisplayNameInput = true;
      });
    } else if (isLogin) {
      updateDisplayName(null);
    } else {
      Navigator.popAndPushNamed(context, "/");
    }
  }

  Future<void> updateDisplayName(String? displayNameInputted) async {
    String displayName = displayNameInputted?? "";

    try {
      displayName = displayName.isEmpty? auth.currentUser!.displayName!.split("%20%")[0] : displayName;
    } catch (e) {
      // expected error cause: displayName == null when hit "continue" when promted
      // TODO: show feedback
    }

    debugPrint("display name from over here: $displayName");

    if (displayName.isNotEmpty) {

      final displayNameAuth = auth.currentUser!.displayName;

      if (displayNameAuth?.split("%20%")[1] != currentDeviceFcmToken) {
        print("Change in fcm token for user of this email... updating...");
        await auth.currentUser!.updateDisplayName("$displayName%20%$currentDeviceFcmToken");
        print("FCM Token updated.");
      }

      Navigator.popAndPushNamed(context, "/");
    } else {
      // TODO: error feedback to user 'Please type in your display name'
    }
  }

  late final Size screenSize;

  @override
  Widget build(BuildContext context) {

    try {
      screenSize = MediaQuery.of(context).size;
    } catch(e) {}

    return showDisplayNameInput? SetDisplayNameScreen(updateDisplayName) : Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 6,
                colors: [
                  Color(0xFFE3F2FD), // Light blue for gradient effect
                  Color(0xFFFFFFFF), // White for subtle transition
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isLogin? 'Hello Again!' : "Hello, Welcome!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    isLogin? "Welcome back, you've been missed!" : "Welcome to chat! All your chats in one place.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 42),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03), // Shadow color
                          blurRadius: 23.5,         // Spread of the shadow
                          offset: Offset(0, 4),  // Position of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.all(17),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        // fillColor: Colors.grey[100],
                        fillColor: Colors.white
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03), // Shadow color
                          blurRadius: 23.5,        // Spread of the shadow
                          offset: Offset(0, 4),  // Position of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.all(17),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        // fillColor: Colors.grey[100],
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey.shade400, size: 19),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  isLogin? SizedBox() : Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03), // Shadow color
                          blurRadius: 23.5,        // Spread of the shadow
                          offset: Offset(0, 4),  // Position of the shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: confirmPassController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        contentPadding: EdgeInsets.all(17),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        // fillColor: Colors.grey[100],
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey.shade400, size: 19),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  isLogin? Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Recovery Password',
                        style: TextStyle(
                          color: Color(0xFF247ff1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ) : SizedBox(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B), // Light red color as per the design
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isLogin? 'Sign In' : "Resgister",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Row(
                  //   children: [
                  //     Expanded(child: Divider()),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //       child: Text('Or continue with'),
                  //     ),
                  //     Expanded(child: Divider()),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),

          // register / sign up option
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Not a member?", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Register
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5)
                  ),
                  child: Text("Register now", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF247ff1)))
                ),
                SizedBox(width: 10)
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    checkAuthStatus();
  }
}