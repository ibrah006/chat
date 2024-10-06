
import 'package:chat/constants/constants.dart';
import 'package:chat/databases/tables/chats.dart';
import 'package:chat/databases/tables.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  
  static late Database database;
  
  static Future<String> getDatabasePath() async {
    final docDir = await getApplicationDocumentsDirectory();
    
    return join(docDir.path, '$DATABASE_NAME.db');
  }

  static Future<void> init() async {

    final String path = await getDatabasePath();

    print("database path: $path");

    database = await openDatabase(
      path,
      version: 1,
      onCreate: _onDbCreate,
    );


  }

  static String getColumns(Tables table) {
    switch(table) {
      case Tables.chats: return ChatsTable.columns;
    }
  }

  static Future<void> _onDbCreate(Database db, int version) async {
    for (Tables table in Tables.values) {
      await db.execute(
      'CREATE TABLE ${table.name} (id INTEGER PRIMARY KEY, ${getColumns(table)})');
    }
  }

  static Future<List<Map<String, Object?>>> get(Tables table, {String? whereColumn, List? args}) async {
    await _check();
    
    final whereQuery = whereColumn!=null? "WHERE $whereColumn = ?" : "";
    final result = await database.rawQuery("SELECT * FROM ${table.name} $whereQuery", args);
    await dispose();
    return result;
  }

  static Future<void> insert(String sql, List values) async {
    try {
      await database.execute(sql, values);
    } on DatabaseException {
      // database not intialized exception
      await init();
      await database.execute(sql, values);
    }

    await dispose();
  }

  static Future<void> update(
    Tables table,
    Map<String, dynamic> values,
    String whereQuery,
    List whereArgs) async {

    await _check();

    await database.update(table.name, values, where: whereQuery, whereArgs: whereArgs);
  }

  static Future<void> _check() async {
    try {
      database;
    } catch(e) {
      await init();
    }

    if (!database.isOpen) await init();
  }

  static Future<void> dispose() async {

    try {
      await database.close();
    } catch(e) {}
  }

}