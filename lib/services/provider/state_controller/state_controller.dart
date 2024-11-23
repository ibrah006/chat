import 'package:chat/services/call/call_state.dart';
import 'package:chat/services/messages/message.dart';
import 'package:chat/users/person.dart';
import 'package:chat/users/users_manager.dart';
import 'package:get/get.dart';
import '../provider_managers.dart';

class MessagesController<T> extends GetxController {
  var data = <Message>[].obs;

  // Inject ApiService using GetX's dependency injection
  final MessagesManager apiService = Get.find();

  void fetchData() {
    data.value = apiService.messages;
  }

  void onCallEnd(Message callMessage) {
    final messageIndex = data.indexWhere((message)=> message.id == callMessage.id);

    data[messageIndex].details.state = CallState.ended;
    data[messageIndex].details.duration = callMessage.details.duration;

    update();
  }

  updateMessageSendingStatus(String messageId) {
    data.firstWhere((message)=> message.id == messageId).isSending = false;
  }

}

class FriendsController<T> extends GetxController {

  var data = <Person>[].obs;

  // Inject ApiService using GetX's dependency injection
  final FriendsManager apiService = Get.find();

  reArrange(userUid) {

    if (userUid == data.first.uid) {
      return;
    }

    data.sort((a, b) {
      if (b.lastMessage == null) {
        return 0;
      } else if (a.lastMessage == null) {
        return 1;
      }

      return b.lastMessage!.datetime.compareTo(a.lastMessage!.datetime);
    });
  }

  updateFcmToken({required String email, required String updatedFcmToken}) {
    final Person user = data.firstWhere((e) => e.email == email);

    user.fcmToken = updatedFcmToken;

    final int userIndex = data.indexWhere((e)=> e.email == email);
    
    data[userIndex] = user;

    update();
  }

  updateLastMessage(Message lastMessage) {
    int friendIndex = data.indexWhere((friend)=> friend.uid == lastMessage.details.uid);
    if (friendIndex == -1) {
      data.add(lastMessage.details);
      friendIndex = data.length - 1;

      // UsersManager.addNewFriend(lastMessage.details.email, userData: lastMessage.details).then((value) {
      //   print("friend ${lastMessage.details.email} added to database");
      // });
    }

    data[friendIndex].lastMessage = lastMessage;

    reArrange(lastMessage.details.uid);

    update();
  }

  updateLastMessageReadStatus(String uid, bool newStatus) {
    final friendIndex = data.indexWhere((friend) {
      return friend.uid == uid;
    });

    // if lastMessage is null or equal to the the newStatus then we dont wwant to unncesarily call update.
    if (data[friendIndex].lastMessage == null || data[friendIndex].lastMessage!.isRead == newStatus) return;

    data[friendIndex].lastMessage!.isRead = newStatus;
    update();
  }

  void fetchData() {
    data.value = apiService.friends;
  }
}