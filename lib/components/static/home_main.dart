import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE3F2FD),
        elevation: 0,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // Notification action
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black87, size: 30),
            onPressed: () {
              // Profile action
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,).copyWith(top: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.03),
                      blurRadius: 23.5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),

            // "Recent Chats" section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Chats',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 10, // example count for recent chats
                        separatorBuilder: (context, index) => Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade50,
                              child: Icon(Icons.person, color: Colors.grey),
                            ),
                            title: Text(
                              'Contact ${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Last message snippet goes here...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '12:34 PM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (index % 3 == 0) // Example unread count
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '3', // Unread count
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Open chat
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start new chat action
        },
        backgroundColor: Color(0xFFFF6B6B),
        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
