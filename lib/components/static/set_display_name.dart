
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetDisplayNameScreen extends StatelessWidget {
  SetDisplayNameScreen(this.updateDisplayName);

  final TextEditingController displayNameController = TextEditingController();

  final Future Function(String? displayName) updateDisplayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              // Title
              Text(
                'Set Display Name',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Choose a name that others will see in chat",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 42),

              // TextField for Display Name
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.03), // Shadow color
                      blurRadius: 23.5,         // Spread of the shadow
                      offset: Offset(0, 4),     // Position of the shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter display name',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.all(17),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  // Save display name action
                  final displayName = displayNameController.text.trim();
                  if (displayName.isNotEmpty) {

                    await updateDisplayName(displayName);

                    // Navigate to next screen or save the name
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Display name set to "$displayName"'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a display name'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF247ff1), // Light red color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  // void updateDisplayName() async {
  //   String displayName = displayNameController.text.trim();

  //   try {
  //     displayName = displayName.isEmpty? auth.currentUser!.displayName!.split("%20%")[0] : displayName;
  //   } catch (e) {
  //     // expected error cause: displayName == null when hit "continue" when promted
  //     // TODO: show feedback
  //   }

  //   debugPrint("display name from over here: $displayName");

  //   if (displayName.isNotEmpty) {

  //     final displayNameAuth = auth.currentUser!.displayName;

  //     if (displayNameAuth?.split("%20%")[1] != currentDeviceFCMToken) {
  //       print("Change in fcm token for user of this email... updating...");
  //       await auth.currentUser!.updateDisplayName("$displayName%20%$currentDeviceFCMToken");
  //       print("FCM Token updated.");
  //     }

  //     Navigator.popAndPushNamed(Get.context!, "/");
  //   } else {
  //     // TODO: error feedback to user 'Please type in your display name'
  //   }
  // }
}
