import 'package:sqflite/sqflite.dart';
import 'package:text_extraction_app/core/constants/app_constants.dart';
import 'package:path/path.dart';
import 'package:text_extraction_app/data/models/extraction_history_model.dart';

class DatabaseHelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.localDatabaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE extraction_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT,
              image_path TEXT,
              extracted_text TEXT,
              created_at TEXT
            )
          ''');
  }

  Future<int> insertExtraction(ExtractionHistoryModel extraction) async {
    final db = await database;
    return await db.insert('extraction_history', extraction.toJson());
  }

  Future<List<ExtractionHistoryModel>> getExtractionsByUser(
    String userId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'extraction_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return ExtractionHistoryModel.fromJson(maps[i]);
    });
  }

  Future<List<ExtractionHistoryModel>> getAllExtractions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'extraction_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ExtractionHistoryModel.fromJson(maps[i]);
    });
  }

  Future<List<ExtractionHistoryModel>> searchExtractions(
    String userId,
    String query,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'extraction_history',
      where: 'user_id = ? AND extracted_text LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return ExtractionHistoryModel.fromJson(maps[i]);
    });
  }

  Future<int> deleteExtraction(int id) async {
    final db = await database;
    return await db.delete(
      'extraction_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
Future<int> deleteAllExtractions(String userId) async {
    final db = await database;
    return await db.delete(
      'extraction_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('extraction_history');
  }
}
