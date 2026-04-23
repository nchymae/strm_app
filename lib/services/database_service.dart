import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    _database ??= await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String pathName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, pathName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        synced INTEGER
      )
    ''');
  }

  Future<void> insertTask(Task task) async {
    final db = await database;

    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;

    final maps = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );

    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getUnsyncedTasks() async {
    final db = await database;

    final maps = await db.query(
      'tasks',
      where: 'synced = ?',
      whereArgs: [0],
    );

    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> markSynced(int id) async {
    final db = await database;

    await db.update(
      'tasks',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}