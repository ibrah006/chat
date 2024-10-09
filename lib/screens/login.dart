

import 'package:chat/widget_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class LoginScreen extends MainWrapperStateful {
  LoginScreen(this.currentDeviceFcmToken);

  final String currentDeviceFcmToken;

  static const Iterable _quickLogins = [
    "ibrah@chatly.com",
    "dell@chatly.com",
    "flutteremu@chatly.com"
  ];


  final emailController = TextEditingController(), passController = TextEditingController(), displayNameController = TextEditingController();

  final auth = FirebaseAuth.instance;

  bool showDisplayNameInput = false;

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
      updateDisplayName();
    } else {
      Navigator.popAndPushNamed(context, "/");
    }
  }

  void updateDisplayName() async {
    String displayName = displayNameController.text.trim();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showDisplayNameInput? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Display name"),
          TextField(
            controller: displayNameController,
          ),
          SizedBox(height: 17.5),
          ElevatedButton(
            onPressed: updateDisplayName,
            child: Text("Continue")
          )
        ],
      )
       : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Welcome!", style: textTheme.headlineMedium!.copyWith(color: Colors.black87)),
          SizedBox(height: 40),
          TextField(
            controller: emailController,
          ),
          TextField(
            controller: passController,
            obscureText: true,
          ),
          SizedBox(height: 17.5),
          ElevatedButton(
            onPressed: login,
            child: Text("Login")
          ),
          SizedBox(height: 50),

          ...List.generate(
            _quickLogins.length,
            (index) {
              return ListTile(
                leading: Text(_quickLogins.elementAt(index)),
                trailing: Radio<String>(
                  value: _quickLogins.elementAt(index),
                  groupValue: selectedQuickLogin,
                  onChanged:(value) {
                    setState(() {
                      selectedQuickLogin = value!;
                    });
                    updateFields();
                  },
                ),
              );
            }
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