

import 'package:chat/services/call/call_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class SomeConcept extends StatelessWidget {
  const SomeConcept({super.key});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80), // Top padding

            // Welcome Title
            Text(
              'Welcome Back!',
              style:  GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              "Let's explore what's new today",
              style:  GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 32),

            // Feature Tiles
            Expanded(
              child: ListView(
                children: [
                  // Chat Feature
                  _buildFeatureTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat with Friends',
                    description: 'Catch up on conversations',
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notifications Feature
                  _buildFeatureTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    description: 'Stay updated on activities',
                    color: Color(0xFF247ff1),
                  ),
                  const SizedBox(height: 16),

                  // Settings Feature
                  _buildFeatureTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    description: 'Adjust your preferences',
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Log Out',
                      style:  GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 23.5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatConcept extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 60,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, left: 10),
            child: CircleAvatar(
              backgroundColor: Color(0xFF247ff1).withOpacity(.2),
              child: Icon(Icons.person_rounded) // replace with actual image
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yusuf', style:  GoogleFonts.poppins(color: Colors.black)),
              Text('Online', style:  GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
          actions: [
            Icon(Icons.phone, color: Color(0xFF247ff1)),
            SizedBox(width: 20),
            Icon(Icons.videocam, color: Color(0xFF247ff1)),
            SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildReceivedMessage('Hello Abdul! Can you check my project at once?', '12:23 PM'),
                  _buildSentMessage('Sure! can you send the link?', '14:33 PM'),
                  _buildReceivedMessage('I’m happy to hear feedback from you.', '14:35 PM'),
                  _buildReceivedImageMessage(),
                  _buildSentMessage('Awesome Work, Dude! 😍', '14:37 PM'),
                ],
              ),
            ),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFFf9f9f9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            SizedBox(height: 4),
            Text(time, style:  GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFF247ff1), // purple color for sent message
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style:  GoogleFonts.poppins(color: Colors.white)),
            SizedBox(height: 4),
            Text(time, style:  GoogleFonts.poppins(fontSize: 10, color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedImageMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://example.com/image.jpg', // replace with actual image
            width: 200,
          ),
          SizedBox(height: 4),
          Text(
            'https://www.figma.com/file/chatappsdesign...',
            style:  GoogleFonts.poppins(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 248, 248, 247),
        borderRadius: BorderRadius.circular(35)
      ),
      child: Row(
        children: [
          Icon(Icons.camera_alt, color: Color(0xFF247ff1)),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintStyle:  GoogleFonts.poppins(color: Colors.grey.shade400),
                hintText: 'Type Here...',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.image, color: Color(0xFF247ff1)),
          SizedBox(width: 8),
          Icon(Icons.send, color: Color(0xFF247ff1)),
        ],
      ),
    );
  }
}

class ChatConcept2 extends StatelessWidget {
  final String displayName;
  final String profileImageUrl;
  final bool isOnline;

  const ChatConcept2({
    Key? key,
    required this.displayName,
    required this.profileImageUrl,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,  // AppBar background color set to white
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 18,
              backgroundColor: Color(0xFF6C63FF).withOpacity(.35),
              child: Icon(Icons.person, size: 27, color: Colors.black87)
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_rounded, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Example Message Bubbles
                _buildMessageBubble(
                  message: "Hello, can you check my project?",
                  isSentByUser: false,
                  time: "12:23 PM",
                ),
                _buildMessageBubble(
                  message: "Sure! Can you send the link?",
                  isSentByUser: true,
                  time: "12:33 PM",
                ),
                _buildMessageBubble(
                  message: "Here's the link: https://example.com",
                  isSentByUser: false,
                  time: "12:35 PM",
                  isLink: true,
                ),
                _buildMessageBubble(
                  message: "Looks great! 👍",
                  isSentByUser: true,
                  time: "12:37 PM",
                ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
      backgroundColor: Colors.grey[100],  // Background color set to light grey
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSentByUser,
    required String time,
    bool isLink = false,
  }) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByUser ? Color(0xFF6C63FF) : Colors.white70,  // Sent bubble: #6C63FF, Received bubble: light grey
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isSentByUser ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isSentByUser ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            isLink
                ? GestureDetector(
                    onTap: () {
                      // Open link
                    },
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.blue[200], decoration: TextDecoration.underline),
                    ),
                  )
                : Text(
                    message,
                    style: TextStyle(
                      color: isSentByUser ? Colors.white : Colors.black87,
                    ),
                  ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(fontSize: 10, color: isSentByUser ? Colors.white70 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,  // Background color of message input area set to white
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],  // Text field container color set to light grey
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class LoginConcept extends StatelessWidget {
  const LoginConcept({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Title
                Text(
                  'Welcome Back!',
                  style:  GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Please log in to continue',
                  style:  GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                
                // Email Text Field
                _buildTextField(
                  hintText: 'Email Address',
                  icon: Icons.email_outlined,
                ),
                SizedBox(height: 16),

                // Password Text Field
                _buildTextField(
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                
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
                  onPressed: () {
                    // Handle sign-in logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 80.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Sign In',
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
                      onPressed: () {
                        // Facebook login logic
                      },
                    ),
                    SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      color: Color(0xFFdb4437),
                      onPressed: () {
                        // Google login logic
                      },
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style:  GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Sign Up screen
                      },
                      child: Text(
                        'Sign Up',
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
  Widget _buildTextField({required String hintText, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Reusable Social Button Widget
  Widget _buildSocialButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
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
}

class CallLogConcept extends StatelessWidget {
  final CallState callState;
  final String callType; // 'Incoming' or 'Outgoing'
  final String callTime; // e.g., "2:15 PM"
  final String duration; // e.g., "5 mins"

  const CallLogConcept({
    required this.callState,
    required this.callType,
    required this.callTime,
    required this.duration
  });

  @override
  Widget build(BuildContext context) {

    final isMissed = callState == CallState.missed;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: Icon(Icons.person, size: 27),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isMissed
                          ? Icons.call_missed_rounded
                          : callState == CallState.incoming || callState == CallState.ongoing || callState == CallState.talking? Icons.call_rounded
                          : Icons.call_end_rounded,
                          // : (isIncomingCall ? Icons.call_received : Icons.call_made),
                      color: isMissed ? Colors.red : Color(0xFF6C63FF),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "$callType Call",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            callState == CallState.incoming || callState == CallState.ongoing? "Waiting for you"
            : callState == CallState.talking? 'Talking'
            : isMissed ? 'Missed Call'
            : "Duration: $duration",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

}