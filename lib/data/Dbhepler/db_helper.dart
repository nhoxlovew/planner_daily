import 'package:planner_daily/data/model/task.dart';
import 'package:planner_daily/data/model/user.dart'; // Ensure you have a User model defined
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('daily_planner.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // Create tasks table
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT,
            content TEXT,
            timeRange TEXT,
            location TEXT,
            organizer TEXT,
            notes TEXT,
            isCompleted INTEGER DEFAULT 0
          )
        ''');

        await setupTestUser(db); // Setup test user
      },
    );
  }

  Future<void> setupTestUser(Database db) async {
    // Check if the test user already exists
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['testuser'],
    );

    if (result.isEmpty) {
      // Insert the test user
      await db.insert(
        'users',
        {'username': 'testuser@gmail.com', 'password': 'password123'},
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Ignore if user already exists
      );
    }
  }

  Future<bool> registerUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      return false; // Handle the error as needed
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first); // Convert the map to a User object
    } else {
      return null; // No user found
    }
  }

  Future<void> createTask(Task task) async {
    print('Adding task: ${task.toMap()}'); // Debug log
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;

    // Ensure you're updating by task ID
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTaskStatistics() async {
    final db = await database;

    // Get the total count of tasks
    final totalTasksCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM tasks')) ??
        0;

    // Get the count of completed tasks
    final completedTasksCount = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM tasks WHERE isCompleted = 1')) ??
        0;

    // Calculate the count of new tasks
    final newTasksCount = totalTasksCount - completedTasksCount;

    // Get the count of tasks in progress
    final inProgressTasksCount = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM tasks WHERE isCompleted = 0')) ??
        0;

    return {
      'completed': completedTasksCount,
      'new': newTasksCount,
      'inProgress': inProgressTasksCount,
    };
  }
}
