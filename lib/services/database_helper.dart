import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gymbro/models/exercise.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  static const String _dbName = 'gymbro.db';
  static const String _tableName = 'exercises';
  static const String _columnId = 'id';
  static const String _columnName = 'name';
  static const String _columnDate = 'date';
  static const String _columnDuration = 'duration';
  static const String _columnReps = 'reps';
  static const String _columnNotes = 'notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnName TEXT NOT NULL,
        $_columnDate TEXT NOT NULL,
        $_columnDuration INTEGER,
        $_columnReps INTEGER,
        $_columnNotes TEXT
      )
    ''');
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert(_tableName, exercise.toMap());
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(_tableName, orderBy: '$_columnDate DESC');
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<List<Exercise>> getExercisesByDate(DateTime date) async {
    final db = await database;

    String dateString = DateTime(date.year, date.month, date.day).toIso8601String().substring(0, 10);

    List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: "SUBSTR($_columnDate, 1, 10) = ?",
      whereArgs: [dateString],
      orderBy: '$_columnId ASC',
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromMap(maps[i]);
    });
  }

  Future<List<DateTime>> getUniqueExerciseDates() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT SUBSTR($_columnDate, 1, 10) as date FROM $_tableName ORDER BY date ASC'
    );
    return maps.map((map) => DateTime.parse(map['date'] as String)).toList();
  }

  Future<bool> hasExerciseForToday() async {
    final db = await database;
    final DateTime now = DateTime.now();
    // Compare only the date part (YYYY-MM-DD)
    final String todayDateString = DateTime(now.year, now.month, now.day).toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: "SUBSTR($_columnDate, 1, 10) = ?",
      whereArgs: [todayDateString],
      limit: 1, // We only need to know if at least one entry exists for today
    );
    return maps.isNotEmpty;
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      _tableName,
      exercise.toMap(),
      where: '$_columnId = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}