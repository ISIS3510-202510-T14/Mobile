// lib/services/upload_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadService {
  static Future<Database> _getDb() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return openDatabase(path);
  }

  static Future<void> uploadErrorLogs() async {
    final db = await _getDb();
    // 1) Fetch pending logs from local table
    final List<Map<String, dynamic>> logs =
        await db.query('error_logs');      // standard sqflite query :contentReference[oaicite:10]{index=10}

    if (logs.isEmpty) return;

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
        'Api-Key': dotenv.env['NEW_RELIC_USER_LICENSE'] ?? '',   // from New Relic account 
        'Content-Type': 'application/json'
      },
      body: jsonEncode(payload),                 // JSON batch format 
    );

    if (response.statusCode == 202 || response.statusCode == 201 ||response.statusCode == 200) {
      // 4) Clear sent logs
      await db.delete('error_logs');
    } else {
      // Optionally log/handle retry
      print('NR Log API error: ${response.statusCode}');
    }
  }
}
