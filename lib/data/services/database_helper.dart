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
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE extraction_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT,
              image_url TEXT,
              cloud_image_url TEXT,
              extracted_text TEXT,
              created_at TEXT
            )
          ''');
  }

  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < newVersion) {
  //     await db.execute('''
  //       CREATE TABLE extraction_history_new(
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         user_id TEXT,
  //         image_url TEXT,
  //         extracted_text TEXT,
  //         created_at TEXT
  //       )
  //     ''');

  //     await db.execute('''
  //       INSERT INTO extraction_history_new (id, user_id, image_url, extracted_text, created_at)
  //       SELECT id, user_id, image_path, extracted_text, created_at
  //       FROM extraction_history
  //     ''');

  //     await db.execute('DROP TABLE extraction_history');

  //     await db.execute(
  //       'ALTER TABLE extraction_history_new RENAME TO extraction_history',
  //     );
  //   }
  // }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE extraction_history ADD COLUMN cloud_image_url TEXT',
      );
    }
  }

  Future<int> insertExtraction(ExtractionHistoryModel extraction) async {
    final db = await database;
    return await db.insert('extraction_history', extraction.toJson());
  }

  // Future<List<ExtractionHistoryModel>> getExtractionsByUser(
  //   String userId,
  // ) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'extraction_history',
  //     where: 'user_id = ?',
  //     whereArgs: [userId],
  //     orderBy: 'created_at DESC',
  //   );
  //   return List.generate(maps.length, (i) {
  //     return ExtractionHistoryModel.fromJson(maps[i]);
  //   });
  // }

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
