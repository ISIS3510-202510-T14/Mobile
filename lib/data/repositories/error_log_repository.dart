// lib/data/repositories/error_log_repository.dart

import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';

/// A repository for logging connection and other errors into local SQLite storage,
/// and querying error counts over time.
class ErrorLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Logs an error for the given [endpoint] and [errorType] with the current UTC timestamp.
  Future<void> logError(String endpoint, String errorType) async {
    await _dbHelper.insertErrorLog(endpoint, errorType);
  }

  /// Returns the total number of errors logged since [ago].
  ///
  /// For example:
  /// ```dart
  /// final count = await ErrorLogRepository().countErrorsSince(Duration(days: 7));
  /// ```
  Future<int> countErrorsSince(Duration ago) async {
    return await _dbHelper.countErrorsSince(ago);
  }
}
