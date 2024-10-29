

import 'package:flutter/material.dart';
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              "Let's explore what's new today",
              style: TextStyle(
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
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
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