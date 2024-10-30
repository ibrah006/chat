

import 'package:chat/services/messages/message.dart';
import 'package:chat/users/person.dart';

class MessagesManager {

  List<Message> messages = [];

}

class FriendsManager {
  FriendsManager(List<Person> initialState) {
    friends = initialState;
  }

  late List<Person> friends;

}