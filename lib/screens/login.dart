

import 'package:chat/components/static/login_main.dart';
import 'package:chat/components/static/set_display_name.dart';
import 'package:chat/constants/dialogs.dart';
import 'package:chat/widget_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    "samsung@chatly.com",
    "vivo@chatly.com"
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

  Future<void> updateDisplayName(String? newDisplayName) async {
    final authname = auth.currentUser!.displayName?.split("%20%");
    final isAuthnameNotEmpty = (authname?.length?? 0) > 1;

    final String? displayNameAuth = isAuthnameNotEmpty? authname![0] : null;

    debugPrint("display name from over here: $displayNameAuth");

    if (newDisplayName != null && newDisplayName.isNotEmpty) {
      // IF UPDATE IN DISPLAY NAME

      try {
        await auth.currentUser!.updateDisplayName("$newDisplayName%20%$currentDeviceFcmToken");

        Navigator.popAndPushNamed(context, "/");
      } catch(e) {
        return;
      }
    } else if (displayNameAuth != null) {
      // if the user has a CHANGE IN FCM TOKEN

      final fcmTokenAuth = authname![1];

      if (fcmTokenAuth != currentDeviceFcmToken) {
        print("Change in fcm token / display name for user of this email... updating...");

        try {
          await auth.currentUser!.updateDisplayName("$displayNameAuth%20%$currentDeviceFcmToken");
          final userUpdatesPath = FirebaseFirestore.instance.collection("updates").doc(auth.currentUser!.uid);
          if ((await userUpdatesPath.get()).exists) {
            await userUpdatesPath.delete();
          }
          await userUpdatesPath.set({
            "fcmToken": currentDeviceFcmToken
          });

          print("FCM Token / Display Name updated.");
          Navigator.popAndPushNamed(context, "/");
        } catch(e) {
          return;
        }
      }
    } else {
      // show feedback to user

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type in a display name to set'),
        ),
      );
    }
  }

  udpateFcmToken() {
    final authname = auth.currentUser!.displayName!.split("%20%");
    final fcmTokenOnServer = authname[1];
    if (fcmTokenOnServer != currentDeviceFcmToken) {
      auth.currentUser!.updateDisplayName("${authname[0]}%20%$currentDeviceFcmToken");
    }
  }

  authenticate() async {
    if (auth.currentUser == null)  {
      if (isLogin) {
        await auth.signInWithEmailAndPassword(email: emailController.text, password: passController.text);
      } else {
        if (passController.text == confirmPassController.text) {
          await auth.createUserWithEmailAndPassword(email: emailController.text, password: passController.text);
          await FirebaseFirestore.instance.collection("users").doc(auth.currentUser!.uid).set({});
        } else {
          // TODO; show some feedack like passwords don't match
        }
      }
      updateDisplayName(displayNameController.text.trim().isEmpty? null : displayNameController.text);
    }
  }

  late final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: showDisplayNameInput? SetDisplayNameScreen(updateDisplayName) : Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Title
                Text(
                  isLogin? 'Welcome Back!' : "Welcome to Chat!",
                  style:  GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  isLogin? 'Please log in to continue' : "Sign up to continue",
                  style:  GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                
                // Email Text Field
                TextField(
                  controller: emailController,
                  decoration: _textFieldDecoration(hintText: 'Email Address', icon: Icons.email_outlined),
                ),
                SizedBox(height: 16),
                // Password Text Field
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: _textFieldDecoration(hintText: "Password", icon: Icons.lock_outline)
                ),

                if (!isLogin) ...[
                  SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    controller: confirmPassController,
                    decoration: _textFieldDecoration(hintText: "Password", icon: Icons.lock),
                  )
                ],
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Add Forgot Password functionality here
                    },
                    child: Text(
                      'Forgot Password?',
                      style:  GoogleFonts.poppins(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Sign In Button
                ElevatedButton(
                  onPressed: authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 80.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    isLogin? 'Sign In' : "Sign up",
                    style:  GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or',
                        style:  GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.facebook,
                      color: Color(0xFF3b5998),
                      onPressed: null
                    ),
                    SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      color: Color(0xFFdb4437),
                      onPressed: null
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin? "Don't have an account?" : "Already registered?",
                      style:  GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Sign Up screen
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin? 'Sign Up' : "Sign in",
                        style:  GoogleFonts.poppins(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable TextField Widget
  InputDecoration _textFieldDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Reusable Social Button Widget
  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  @override
  void initState() {
    super.initState();
    
    checkAuthStatus();
  }
}