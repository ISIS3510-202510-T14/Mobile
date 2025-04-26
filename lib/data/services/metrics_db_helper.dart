import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class MetricsDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'metrics.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT,
            duration INTEGER,
            statusCode INTEGER,
            success INTEGER,
            error TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> insertMetric(Map<String, dynamic> metric) async {
    print('[DB Helper] Inserting metric: $metric');
    final db = await database;
    await db.insert('metrics', metric);

  }

  static Future<List<Map<String, dynamic>>> getAllMetrics() async {
    final db = await database;
    return await db.query('metrics');
  }

  static Future<void> deleteAllMetrics() async {
    final db = await database;
    await db.delete('metrics');
  }
}
