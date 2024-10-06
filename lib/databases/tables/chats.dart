
import 'package:chat/databases/local_database.dart';
import 'package:chat/databases/tables.dart';
import 'package:chat/users/person.dart';
import 'package:flutter/material.dart';

class ChatsTable {
  
  static const table = Tables.chats;

  static const columns = "uid TEXT, email TEXT, displayName TEXT, fcmToken TEXT";

  static String _modifyColumnsForInsert() {
    return columns.replaceAll("TEXT", "");
  }

  static Future<void> insert(ChatsTableRow row) async {

    // Check to make sure no duplicates are added
    final result = await LocalDatabase.get(table, whereColumn: "uid", args: [row.uid]);
    if (result.isNotEmpty) {
      // notification to the developer
      debugPrint("Failed to add duplicate into table $table.");
      return;
    }

    await LocalDatabase.insert(
      "INSERT INTO ${table.name}(${_modifyColumnsForInsert()}) VALUES(?, ?, ?, ?)",
      [row.uid, row.email, row.displayName]
    );

    // notification to the developer
    debugPrint("${row.toString()} successfully added to the table $table.");
  }

  static Future<void> update(Person person) async {
    await LocalDatabase.update(table, person.toMap(), "uid = ?", [person.uid]);
  }

}

class ChatsTableRow extends Person {
  ChatsTableRow(Person info) : super(info.uid, info.email, displayName: info.displayName, fcmToken: info.fcmToken);

  @override
  String toString() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "fcmToken": fcmToken
    }.toString();
  }
}

