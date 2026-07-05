import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'schema.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static Database? _database;

  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ironlog.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    
    // Safety net: if tables were created but seeding failed/aborted previously
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM exercises');
      final count = result.first['count'] as int? ?? 0;
      if (count == 0) {
        await SeedData.seedAll(db);
      }
    } catch (e) {
      // Ignored, tables might not exist yet if something went horribly wrong
    }
    
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // sqflite's db.execute() only processes ONE SQL statement per call.
    // Both SQL strings contain multiple statements separated by ';'.
    // We must split them and execute each statement individually.
    for (final sql in _splitStatements(createTablesSQL)) {
      await db.execute(sql);
    }
    for (final sql in _splitStatements(createIndexesSQL)) {
      await db.execute(sql);
    }
    
    // Seed initial data (exercises, workout days, config)
    await SeedData.seedAll(db);
  }

  static List<String> _splitStatements(String sql) {
    return sql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map>> query(
    String table, {
    dynamic where,
    List? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    dynamic where,
    List? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    dynamic where,
    List? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<Map?> getById(String table, int id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> getCount(String table, {String? where, List? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<T> transaction<T>(Future<T> Function(Transaction tx) fn) async {
    final db = await database;
    return await db.transaction(fn);
  }

  Future<bool> isTableEmpty(String table) async {
    return await getCount(table) == 0;
  }

  Future<Map<String, dynamic>?> getConfig(String key) async {
    final db = await database;
    final results = await db.query(
      'app_config',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> setConfig(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
