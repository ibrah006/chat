

import 'package:chat/constants/constants.dart';
import 'package:chat/databases/local_database.dart';
import 'package:chat/databases/tables.dart';
import 'package:sqflite/sqflite.dart';

class DeveloperDebug {

  bool showTimeSinceStart = false;

  /// show time since the app started/restarted
  void toggleShowTimeSinceStart({bool? newState}) {
    showTimeSinceStart = newState?? !showTimeSinceStart;
  }

  static Future deleteDatabase() async {

    print("delete databsaes selected");

    databaseFactory.deleteDatabase(await LocalDatabase.getDatabasePath());
    await LocalDatabase.dispose();
  }

  static Future<void> runOptions(int index) async {

    print("we are running dev options");

    switch(index) {
      case 0: await deleteDatabase();
    }
  }

}