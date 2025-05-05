// lib/data/services/backend_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repositories/error_log_repository.dart';
import 'metrics_management.dart' as metrics_management;
import 'package:campus_picks/src/config.dart';

class BackendApi {
  static const _base = '${Config.apiBaseUrl}/api';

  /// POST /users      (used at sign‑up)
  static Future<void> registerUser({
    required String uid,
    required String email,
    String? name,
    String? phone,
  }) async {
    final stopwatch = Stopwatch()..start();
    int? statusCode;
    bool success = false;
    String? error;

    try {
      final res = await http.post(
        Uri.parse('$_base/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': uid,
          'email': email,
          'name': name,
          'phone': phone,
          'balance': 0,
        }),
      );
      stopwatch.stop();
      statusCode = res.statusCode;
      success = res.statusCode == 200 || res.statusCode == 201;

      if (!success) {
        error = res.body;
        throw Exception('Backend registration failed: $error');
      }
    } catch (e) {
      stopwatch.stop();
      error = e.toString();
      await ErrorLogRepository().logError('/api/users', e.runtimeType.toString());
      rethrow;
    } finally {
      await metrics_management.logApiMetric(
        endpoint: '/api/users',
        duration: stopwatch.elapsedMilliseconds,
        statusCode: statusCode,
        success: success,
        error: error,
      );
    }
  }


  /// GET /auth/login?uid=<uid>   (used at sign‑in)
  /// • 200 OK  → user exists ‑ continue
  /// • 404     → uid not found ‑ treat as login error
  static Future<void> verifyLogin(String uid) async {
    final stopwatch = Stopwatch()..start();
    int? statusCode;
    bool success = false;
    String? error;

    try {
      final res = await http.get(
        Uri.parse('$_base/auth/login')
            .replace(queryParameters: {'uid': uid}),
      );
      stopwatch.stop();
      statusCode = res.statusCode;
      success = res.statusCode == 200;

      if (!success) {
        error = res.body;
        throw Exception('User does not exist in backend');
      }
    } catch (e) {
      stopwatch.stop();
      error = e.toString();
      await ErrorLogRepository().logError('/api/auth/login', e.runtimeType.toString());
      rethrow;
    } finally {
      await metrics_management.logApiMetric
      (
        endpoint: '/api/auth/login',
        duration: stopwatch.elapsedMilliseconds,
        statusCode: statusCode,
        success: success,
        error: error,
      );
    }
  }
}
