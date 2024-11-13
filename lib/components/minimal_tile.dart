
import 'package:chat/constants/date.dart';
import 'package:chat/users/person.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MinimalTile extends StatelessWidget {
  final Person user;
  final String profileImageUrl;
  final bool isOnline;
  final bool isPinned;

  final Function(Person person) chatScreenCallBack;

  MinimalTile(
    this.user, {
    Key? key,
    required this.profileImageUrl,
    this.isOnline = false,
    this.isPinned = false,
    required this.chatScreenCallBack
  }) : super(key: key);

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    

    final String userFcmToken = user.fcmToken;
    final bool showFcmWarning = userFcmToken.isEmpty;
            
    print("friend: ${user.toMap()}");

    final name = "${user.displayName!}${user.uid == auth.currentUser!.uid? " (You)" : ""}";

    final lastMessage = user.lastMessage;

    final time = lastMessage!=null? DateManager.formatDateTime(lastMessage.datetime) : null;

    const isOnline = false;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: lastMessage==null? 0 : 8.0).copyWith(right: 24),
      leading: Stack(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 24,
            // backgroundImage: NetworkImage(profileImageUrl),
            child: Icon(Icons.person, size: 28)
          ),
          // Online Status Indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showFcmWarning) ...[
                SizedBox(width: 13),
                Text("FCM TOKEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.75)),
                Icon(Icons.warning_rounded, color: Colors.red.shade400)
              ]
            ],
          ),
          Text(
            lastMessage!=null? "${lastMessage.isSender? "You: " : ""}${lastMessage.text}" : "Click here to start messaging",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: user.lastMessage==null? IconButton(
        onPressed: () {

        },
        icon: Icon(
          isPinned? Icons.push_pin : Icons.push_pin_outlined,
          color: Colors.grey[500],
        ),
      ) : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (time!=null) Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          if (user.lastMessage?.isRead == false) Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: Colors.red.shade400,//Color(0xFFFF6B6B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(padding: EdgeInsets.only(top: 4), child: SizedBox())
          ),
        ],
      ),  
      onTap: () {
        // Navigate to the chat screen or perform other actions
        chatScreenCallBack(user);
      },
    );
  }
}