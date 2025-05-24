import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles local counting and upload of simple user metrics to New Relic.
class UserMetricsService {
  static const String _betKey = 'incomplete_bet_count';
  static const String _regKey = 'incomplete_registration_count';

  /// Increment the counter for users leaving the place bet view without betting.
  static Future<void> incrementIncompleteBet() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_betKey) ?? 0;
    await prefs.setInt(_betKey, current + 1);
  }

  /// Increment the counter for users abandoning registration.
  static Future<void> incrementIncompleteRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_regKey) ?? 0;
    await prefs.setInt(_regKey, current + 1);
  }

  /// Retrieve and clear the stored count for the given key.
  static Future<int> _takeCount(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(key) ?? 0;
    if (count > 0) await prefs.remove(key);
    return count;
  }

  /// Upload any pending metric counts to New Relic.
  static Future<void> sendPendingMetrics() async {
    final betCount = await _takeCount(_betKey);
    final regCount = await _takeCount(_regKey);

    if (betCount == 0 && regCount == 0) return;

    final logs = <Map<String, dynamic>>[];
    final now = DateTime.now().toUtc().toIso8601String();

    if (betCount > 0) {
      logs.add({
        'type': 'user_metric',
        'metric': 'incomplete_bet',
        'count': betCount,
        'timestamp': now,
      });
    }
    if (regCount > 0) {
      logs.add({
        'type': 'user_metric',
        'metric': 'incomplete_registration',
        'count': regCount,
        'timestamp': now,
      });
    }

    final payload = [
      {
        'common': {
          'attributes': {
            'app': 'MyFlutterApp',
            'environment': 'prod',
          }
        },
        'logs': logs,
      }
    ];

    final uri = Uri.https('log-api.newrelic.com', '/log/v1');
    final response = await http.post(
      uri,
      headers: {
        'Api-Key': dotenv.env['NEW_RELIC_USER_LICENSE'] ?? '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 202) {
      // restore counts on failure so we retry next launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_betKey, (prefs.getInt(_betKey) ?? 0) + betCount);
      await prefs.setInt(_regKey, (prefs.getInt(_regKey) ?? 0) + regCount);
    }
  }
}
