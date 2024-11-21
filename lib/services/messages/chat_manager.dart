
import 'package:chat/services/messages/message.dart';
import 'package:sqflite/sqflite.dart';

class ChatManager {
  final List<Message> inMemoryMessages = [];
  final int inMemoryLimit = 100; // Adjust based on your memory constraints
  late Database database;

  // Initialize the database
  Future<void> initDatabase() async {
    database = await openDatabase(
      'messages.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE Messages(id INTEGER PRIMARY KEY, content TEXT, timestamp INTEGER)',
        );
      },
    );
  }

  // Add a new message and save it directly to the database
  Future<void> addMessage(Message message) async {
    inMemoryMessages.add(message);
    await database.insert('Messages', message.toMap());

    // If memory exceeds limit, offload oldest messages
    if (inMemoryMessages.length > inMemoryLimit) {
      inMemoryMessages.removeAt(0); // Remove the oldest message from memory
    }
  }

  // Load a batch of older messages when scrolling up
  Future<List<Message>> loadOlderMessages(int offset, int limit) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'Messages',
      orderBy: 'timestamp DESC',
      offset: offset,
      limit: limit,
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  // Example function to dynamically manage in-memory messages based on scrolling
  // void onScroll(double scrollOffset) {
  //   // Check if certain messages should be offloaded
  //   // Custom logic to determine which messages to offload based on scrollOffset
  //   if (scrollOffset > someThreshold) {
  //     // Offload oldest messages as they are far off-screen
  //     while (inMemoryMessages.length > inMemoryLimit) {
  //       inMemoryMessages.removeAt(0);
  //     }
  //   }
  // }
}