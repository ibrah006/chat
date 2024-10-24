import 'package:chat/services/messages/message.dart';
import 'package:get/get.dart';
import '../messages_manager.dart';

class MessagesController<T> extends GetxController {
  var data = <Message>[].obs;

  // Inject ApiService using GetX's dependency injection
  final MessagesManager apiService = Get.find();

  void fetchData() {
    data.value = apiService.messages;
  }
}