import 'package:chat/services/provider/state_controller/state_controller.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

enum _AddState {
  adding, added, anonymous, available
}

class _Add {
  _Add(Person person, _AddState initialState) {
    uid = person.uid!;

    addState = initialState; 
  }

  late final String uid;

  late _AddState addState;
}

class UserSearchScreen extends StatefulWidget {

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {

  final TextEditingController searchController = TextEditingController();

  final FriendsController friendsController = Get.put(FriendsController());

  final List<Person> usersFound = [];

  bool isSearching = false;
  

  /// holds user uuids and gets removed once they're added
  final List<String> usersAdding = [];

  void addUserCallback(Person user) async {
    // Add user action

    setState(() {
      usersAdding.add(user.uid!);
    });

    // await UsersManager.addNewFriend(user.email!, userData: user);
    // friendsController.data.add(user);
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      usersAdding.remove(user.uid!);
    });
  }

  void search() async {
    final searchUserEmail = searchController.text;

    setState(() {
      isSearching = true;
    });

    if (!searchUserEmail.isEmail) {
      //TODO: show error to user
      showSnackBar(searchUserEmail.trim().isEmpty? "Please enter an email" : 'Please enter a valid email');
      return;
    } else {
      final userInfo = await UsersManager.searchUser(searchUserEmail);
    
      if (userInfo!=null) {
        setState(() {
          usersFound.add(userInfo);
        });
        showSnackBar("User found");
      } else {
        showSnackBar("User not found");
      }

      searchController.clear();
    }

    setState(() {
      isSearching = false;
    });
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Find',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onSubmitted: (value)=> search(),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          const SizedBox(height: 10),
          if (isSearching) const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: Color(0xFF247ff1),
            ),
          ),

          Expanded(
            child: ListView.builder(
                itemCount: usersFound.length, // Example count, replace with dynamic count
                itemBuilder: (context, index) {

                final user = usersFound.reversed.toList()[index];

                late final bool isUserInFriendList;
                try {
                  friendsController.data.firstWhere((friend)=> friend.uid == user.uid);
                  isUserInFriendList = true;
                } catch(e) {
                  isUserInFriendList = false;
                }

                late final bool isUserInChatly = user.displayName != null;

                final isAddingThisUser = usersAdding.contains(user.uid);

                late final _AddState state;
                if (isAddingThisUser) {
                  state = _AddState.adding;
                } else if (isUserInChatly) {

                  if (isUserInFriendList) {
                    state = _AddState.added;
                  } else {
                    state = _AddState.available;
                  }

                } else if (!isUserInChatly) {
                  state = _AddState.anonymous;
                }

                return UserTile(
                  user: user,
                  state: state,
                  onAddPressed: isAddingThisUser || !isUserInChatly || isUserInFriendList? null : ()=> addUserCallback(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       decoration: const BoxDecoration(
  //         gradient: RadialGradient(
  //           center: Alignment.topCenter,
  //           radius: 6,
  //           colors: [
  //             Color(0xFFE3F2FD), // Light blue for gradient effect
  //             Color(0xFFFFFFFF), // White for subtle transition
  //           ],
  //         ),
  //       ),
  //       padding: const EdgeInsets.symmetric(horizontal: 32.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 80), // Top padding
  //           Text(
  //             'Add New Friends',
  //             style: TextStyle(
  //               fontSize: 28,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Find friends and start chatting',
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.black54,
  //             ),
  //           ),
  //           const SizedBox(height: 32),
            
  //           // Search Field
  //           TextField(
  //             controller: searchController,
  //             decoration: InputDecoration(
  //               hintText: 'Search by username or email',
  //               prefixIcon: Icon(Icons.search, color: Colors.black54),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10),
  //                 borderSide: BorderSide.none,
  //               ),
  //               filled: true,
  //               fillColor: Color(0xFFF1F1F1),
  //             ),
  //           ),
  //           const SizedBox(height: 24),

  //           // Results List
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: 10, // Replace with actual search results count
  //               itemBuilder: (context, index) {
  //                 return ListTile(
  //                   leading: CircleAvatar(
  //                     backgroundColor: Colors.blueAccent,
  //                     child: Icon(Icons.person, color: Colors.white),
  //                   ),
  //                   title: Text(
  //                     'User Name $index', // Replace with actual user data
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   subtitle: Text(
  //                     'username_$index@example.com',
  //                     style: TextStyle(
  //                       color: Colors.black54,
  //                     ),
  //                   ),
  //                   trailing: ElevatedButton(
  //                     onPressed: () {
  //                       // Add friend action
  //                     }, // ibrah@chatly.com
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blueAccent,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     child: Text('Add'),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  
  
  // @override
  // Widget build(BuildContext context) {

  //   return Scaffold(
  //     body: Container(
  //       decoration: const BoxDecoration(
  //         gradient: RadialGradient(
  //           center: Alignment.topCenter,
  //           radius: 6,
  //           colors: [
  //             Color(0xFFE3F2FD), // Light blue for gradient effect
  //             Color(0xFFFFFFFF), // White for subtle transition
  //           ],
  //         ),
  //       ),
  //       padding: const EdgeInsets.symmetric(horizontal: 32.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 80), // Top padding

  //           // Title
  //           Text(
  //             'Add Friends',
  //             style: GoogleFonts.poppins(
  //               fontSize: 28,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           const SizedBox(height: 8),

  //           // Subtitle
  //           Text(
  //             "Search and add friends to start chatting",
  //             style: GoogleFonts.poppins(
  //               fontSize: 16,
  //               color: Colors.black54,
  //             ),
  //           ),
  //           const SizedBox(height: 32),

  //           // Search Bar
  //           Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(12),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 10,
  //                   offset: Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: TextField(
  //               controller: searchController,
  //               onSubmitted: (value) => search(),
  //               decoration: InputDecoration(
  //                 hintText: 'Search users...',
  //                 hintStyle: GoogleFonts.poppins(
  //                   color: Colors.grey,
  //                   fontSize: 14,
  //                 ),
  //                 border: InputBorder.none,
  //                 prefixIcon: Icon(Icons.search, color: Colors.grey),
  //                 contentPadding: const EdgeInsets.symmetric(vertical: 16),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),

  //           if (isSearching) const Align(
  //             alignment: Alignment.center,
  //             child: CircularProgressIndicator(
  //               color: Color(0xFF247ff1),
  //             ),
  //           ),

  //           // User List
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: usersFound.length, // Example count, replace with dynamic count
  //               itemBuilder: (context, index) {

  //                 final user = usersFound.reversed.toList()[index];

  //                 final displayName = user.displayName;

  //                 late final bool isUserInFriendList;
  //                 try {
  //                   friendsController.data.firstWhere((friend)=> friend.uid == user.uid);
  //                   isUserInFriendList = true;
  //                 } catch(e) {
  //                   isUserInFriendList = false;
  //                 }

  //                 late final bool isUserInChatly = user.displayName != null;

  //                 final isAddingThisUser = usersAdding.contains(user.uid);

  //                 return Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 8.0),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(12),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withOpacity(0.05),
  //                           blurRadius: 10,
  //                           offset: Offset(0, 4),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         CircleAvatar(
  //                           radius: 24,
  //                           backgroundColor: Colors.grey[300],
  //                           child: Icon(Icons.person, color: Colors.white),
  //                         ),
  //                         const SizedBox(width: 16),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 displayName?? "Anonymous[${user.email!.split("@")[0]}]",
  //                                 style: GoogleFonts.poppins(
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: isUserInChatly? 16 : 14.5,
  //                                   color: Colors.black87,
  //                                 ).copyWith(overflow: TextOverflow.ellipsis),
  //                               ),
  //                               Text(
  //                                 isUserInChatly? "User found" : "This user is not on chatly",
  //                                 style: TextStyle(fontSize: 13, color: Colors.black54, overflow: TextOverflow.ellipsis))
  //                             ],
  //                           ),
  //                         ),
  //                         ElevatedButton(
  //                           onPressed: isAddingThisUser || !isUserInChatly || isUserInFriendList? null : () async {
  //                             // Add user action

  //                             setState(() {
  //                               usersAdding.add(user.uid!);
  //                             });

  //                             await UsersManager.addNewFriend(user.email!, userData: user);
  //                             friendsController.data.add(user);

  //                             setState(() {
  //                               usersAdding.remove(user.uid!);
  //                             });
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Color(0xFF247ff1),
  //                             padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(left: 11),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: Wrap(
  //                             children: [
  //                               if (isAddingThisUser) Container(
  //                                 width: 24,
  //                                 height: 24,
  //                                 padding: const EdgeInsets.all(2.0),
  //                                 child: const CircularProgressIndicator(
  //                                   color: Colors.white,
  //                                   strokeWidth: 3,
  //                                 ),
  //                               ) else Icon(isUserInFriendList? Icons.check_rounded : Icons.add_rounded, color: Colors.white),
  //                               SizedBox(width: 7),
  //                               Text(
  //                                 isAddingThisUser? "Adding" : !isUserInChatly? "Invite" : isUserInFriendList? "Already friends" : 'Add',
  //                                 style: TextStyle(color: Colors.white),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class UserTile extends StatelessWidget {

  final Person user;
  final VoidCallback? onAddPressed;

  const UserTile({
    Key? key,
    required this.user,
    required this.onAddPressed,
    required this.state
  }) : super(key: key);

  final _AddState state;

  @override
  Widget build(BuildContext context) {

    print("add state: (${user.displayName}) : $state");

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: Stack(
        children: [
          // User Profile Image
          CircleAvatar(
            radius: 24,
            child: Icon(Icons.person, size: 27)
          ),
          // Online Status Indicator - constant to offline for now
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey,
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
          Text(
            user.displayName?? "Anonymous[${user.email!.split("@")[0]}]",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DefaultTextStyle(
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            child: Row(
              children: [
                if (state == _AddState.anonymous) const Text("This user not in chatly")
                else if (state == _AddState.added) const Text("Cannot add user"),
                SizedBox(width: 10),
                if (state == _AddState.anonymous) InkWell(
                  onTap: () {},                
                  child: Icon(Icons.info_outline, color: Colors.grey, size: 21.5),
                )
              ],
            ),
          )
        ],
      ),
      trailing: ElevatedButton(
        onPressed: onAddPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == _AddState.adding) Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ) else Icon(state == _AddState.added? Icons.check_rounded : Icons.add_rounded, color: Colors.white),
            SizedBox(),
            Text(
              state == _AddState.adding? "Adding" : state == _AddState.added? "Added" : 'Add',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


/*
class UserSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Friends"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
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
            // Search Bar`
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search by name or username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Example list count; replace with dynamic data
                itemBuilder: (context, index) {
                  return _UserListItem(
                    username: "user$index",
                    displayName: "User $index",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for each user list item
class _UserListItem extends StatelessWidget {
  final String username;
  final String displayName;

  _UserListItem({required this.username, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade50,
              child: Icon(Icons.person, color: Colors.blue.shade700),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/