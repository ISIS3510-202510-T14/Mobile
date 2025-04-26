import 'dart:convert';
import 'package:http/http.dart' as http;
import 'metrics_db_helper.dart';
import 'package:intl/intl.dart';
import '../repositories/error_log_repository.dart';
import 'package:campus_picks/src/config.dart';



Future<void> sendPendingMetrics() async {
  final metrics = await MetricsDatabase.getAllMetrics();

  print('[PM] Metrics is $metrics');

  if (metrics.isEmpty) return;

  final url = Uri.parse('${Config.apiBaseUrl}/analytics/metrics/');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(metrics),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await MetricsDatabase.deleteAllMetrics();
    } else {
      print('Failed to send metrics: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending metrics: $e');
    await ErrorLogRepository()
          .logError('/analytics/metrics', e.runtimeType.toString());
      rethrow;
  }
}

Future<void> logApiMetric({
  required String endpoint,
  required int duration,
  int? statusCode,
  required bool success,
  String? error,
}) async {
  final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  final metric = {
    'endpoint': endpoint,
    'duration': duration,
    'statusCode': statusCode,
    'success': success ? 1 : 0,
    'error': error ?? '',
    'timestamp': now,
  };

  await MetricsDatabase.insertMetric(metric);

  print('API Metric logged: $metric');	
}
