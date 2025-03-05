import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:poopapp/core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create children table
    await db.execute('''
      CREATE TABLE ${AppConstants.childTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        avatar_path TEXT
      )
    ''');

    // Create poops table
    await db.execute('''
      CREATE TABLE ${AppConstants.poopTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        date_time TEXT NOT NULL,
        consistency INTEGER NOT NULL,
        color INTEGER NOT NULL,
        feeling INTEGER,
        notes TEXT,
        has_blood INTEGER NOT NULL DEFAULT 0,
        has_mucus INTEGER NOT NULL DEFAULT 0,
        images TEXT,
        FOREIGN KEY (child_id) REFERENCES ${AppConstants.childTableName} (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here as we update the app
    if (oldVersion < 2) {
      // Future migration changes would go here
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
  }
} 