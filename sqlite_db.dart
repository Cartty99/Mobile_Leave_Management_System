/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalDb {
  static Database? _db;
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "leave_app.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) async {
        await newDb.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            surname TEXT,
            email TEXT UNIQUE,
            contactDetails TEXT,
            role TEXT,
            leaveBalance INTEGER,
            profilePictureUrl TEXT
          )
        ''');
        await newDb.execute('''
          CREATE TABLE leave_types (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT
          )
        ''');
        await newDb.execute('''
          CREATE TABLE leaves (
            id TEXT PRIMARY KEY,
            employeeId TEXT,
            leaveTypeId TEXT,
            startDate TEXT,
            endDate TEXT,
            reason TEXT,
            status TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }
}
*/