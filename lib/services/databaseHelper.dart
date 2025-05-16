import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "goodsPriceDB.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    // /data/user/0/com.example.goodsprice/databases/myDatabase.db

    // String path = join("/sdcard/Download/", _databaseName);
    // debugPrint("Path : $path");

    // MUST DELETE OLD DATABASE OR ELSE IT WONT UPDATE
    return openDatabase(path, version: _databaseVersion,
        onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE StoreNames (
            store_id INTEGER PRIMARY KEY,
            store_name TEXT UNIQUE COLLATE NOCASE NOT NULL
          )
          ''');
      debugPrint("StoreNames table created");
      await db.execute('''
          CREATE TABLE ItemNames (
            item_id INTEGER PRIMARY KEY,
            item_name TEXT UNIQUE COLLATE NOCASE NOT NULL
          )
          ''');
      debugPrint("ItemNames table created");
      await db.execute('''
         CREATE TABLE Price (
            item_id INTEGER NOT NULL,
            store_id INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (item_id) REFERENCES ItemNames(item_id),
            FOREIGN KEY (store_id) REFERENCES StoreNames(store_id)
          ) 
          ''');
      debugPrint("Price table created");
      await db.execute('''
         CREATE UNIQUE INDEX itemStores ON Price (item_id, store_id) 
          ''');
      debugPrint("Unique Index created");
    });
  }
}
// EXAMPLE FOR Finances
// CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, username TEXT NOT NULL, hash TEXT NOT NULL, cash NUMERIC NOT NULL DEFAULT 10000.00);
// CREATE TABLE sqlite_sequence(name,seq);
// CREATE UNIQUE INDEX username ON users (username);
// CREATE TABLE stocks (id INTEGER PRIMARY KEY NOT NULL, symbol TEXT UNIQUE COLLATE NOCASE NOT NULL);
// CREATE TABLE usershares (users_id INTEGER NOT NULL, stocks_id INTEGER
// NOT NULL, shares INTEGER NOT NULL, FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY (stocks_id) REFERENCES stocks(id) ON DELETE CASCADE );
// // CREATE UNIQUE INDEX userstocks ON usershares (users_id, stocks_id);
// CREATE INDEX stockssymbol ON stocks(symbol);
// CREATE INDEX usershares_users_id ON usershares(users_id);
// CREATE INDEX usershares_stocks_id ON usershares(stocks_id);
// CREATE TABLE sells (users_id INTEGER NOT NULL, stocks_id INTEGER NOT NULL, shares INTEGER NOT NULL, price REAL NOT NULL, time TEXT NOT NULL, FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY (stocks_id) REFERENCES stocks(id) ON DELETE CASCADE);
// CREATE TABLE purchases (users_id INTEGER NOT NULL, stocks_id INTEGER NOT NULL, shares INTEGER NOT NULL, price REAL NOT NULL, time TEXT NOT NULL, FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY (stocks_id) REFERENCES stocks(id) ON DELETE CASCADE);

// // Insert
// Future<int> insert(Map<String, dynamic> row) async {
//   Database db = await instance.database;
//   return await db.insert(table, row);
// }

// // Query all
// Future<List<Map<String, dynamic>>> queryAllRows() async {
//   Database db = await instance.database;
//   return await db.query(table);
// }

// // Update
// Future<int> update(Map<String, dynamic> row) async {
//   Database db = await instance.database;
//   int id = row[columnId];
//   return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
// }

// // Delete
// Future<int> delete(int id) async {
//   Database db = await instance.database;
//   return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
// }
