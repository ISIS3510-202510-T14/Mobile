// lib/services/upload_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../repositories/error_log_repository.dart'; // <-- Add this import
import '../services/database_helper.dart';

class UploadService {
   static Future<Database> _getDb() async {
     // Use the shared DatabaseHelper (matches.db v5+) so error_logs exists
     return DatabaseHelper().database;
   }

  static Future<void> uploadErrorLogs() async {
    print('Uploading error logs to New Relic...');
    final db = await _getDb();
    // 1) Fetch pending logs from local table
    final List<Map<String, dynamic>> logs =
        await db.query('error_logs');

    if (logs.isEmpty) return;
    print('Found ${logs.length} error logs to upload.');

    // 2) Build New Relic Log API payload
    final payload = [
      {
        'common': {
          'attributes': {
            'app': 'MyFlutterApp',
            'environment': 'prod',
          }
        },
        'logs': logs.map((log) => {
          'type': 'conn_errors',
          'timestamp': log['timestamp'],
          'message': log['message'],
          'endpoint': log['endpoint'],
        }).toList()
      }
    ];

    // 3) Send to New Relic
    final uri = Uri.https('log-api.newrelic.com', '/log/v1');
    final response = await http.post(
      uri,
      headers: {
        'Api-Key': dotenv.env['NEW_RELIC_USER_LICENSE'] ?? '',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(payload),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 202 || response.statusCode == 201 || response.statusCode == 200) {
      // 4) Clear sent 
      print('Successfully uploaded logs to New Relic.');
      await db.delete('error_logs');
    } else {
      // Optionally log/handle retry
      print('Failed to upload logs: ${response.statusCode}');
      print('NR Log API error: ${response.statusCode}');
      // Log the error using ErrorLogRepository
      await ErrorLogRepository().logError(
        'NewRelicLogAPI',
        'Failed to upload logs: ${response.statusCode}',
      );
    }
  }
}