import 'package:chat/services/messages/message.dart';
import 'package:chat/users/person.dart';
import 'package:get/get.dart';
import '../provider_managers.dart';

class MessagesController<T> extends GetxController {
  var data = <Message>[].obs;

  // Inject ApiService using GetX's dependency injection
  final MessagesManager apiService = Get.find();

  void fetchData() {
    data.value = apiService.messages;
  }
}

class FriendsController<T> extends GetxController {

  var data = <Person>[].obs;

  // Inject ApiService using GetX's dependency injection
  final FriendsManager apiService = Get.find();

  updateLastMessage(Message lastMessage) {
    int friendIndex = data.indexWhere((friend)=> friend.uid == lastMessage.details.uid);
    if (friendIndex == -1) {
      data.add(lastMessage.details);
      friendIndex = data.length - 1;
    }

    data[friendIndex].lastMessage = lastMessage;
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