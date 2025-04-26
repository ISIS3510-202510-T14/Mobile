// lib/data/services/isolate_manager.dart

import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repositories/error_log_repository.dart';
import 'package:campus_picks/src/config.dart';

/// Types of background tasks
enum TaskType { syncDrafts }

/// Internal message passed between isolates.
class TaskMessage {
  final TaskType type;
  final dynamic payload;
  final SendPort replyTo;

  TaskMessage({
    required this.type,
    this.payload,
    required this.replyTo,
  });
}

/// Singleton manager for a long‑lived background isolate.
class IsolateManager {
  static final IsolateManager _instance = IsolateManager._internal();
  factory IsolateManager() => _instance;
  IsolateManager._internal();

  late final Isolate _isolate;
  late final SendPort _sendPort;
  final Completer<void> _ready = Completer<void>();

  /// Spawn the isolate; call once at app startup.
  Future<void> initialize() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    _sendPort = await receivePort.first as SendPort;
    _ready.complete();
  }

  /// Enqueue a background task; returns the isolate’s response.
  Future<dynamic> enqueue(TaskType type, dynamic payload) async {
    await _ready.future;
    final responsePort = ReceivePort();
    final message = TaskMessage(
      type: type,
      payload: payload,
      replyTo: responsePort.sendPort,
    );
    _sendPort.send(message);
    final result = await responsePort.first;
    responsePort.close();
    return result;
  }

  /// Entry point for the spawned isolate.
  static void _isolateEntry(SendPort initialSendPort) {
    final port = ReceivePort();
    initialSendPort.send(port.sendPort);

    port.listen((raw) async {
      if (raw is TaskMessage) {
        try {
          switch (raw.type) {
            case TaskType.syncDrafts:
              final drafts = raw.payload as List<dynamic>;
              final List<Map<String, String>> succeeded = [];
              for (final d in drafts) {
                final map = d as Map<String, dynamic>;
                final ok = await _sendDraft(map);
                if (ok) {
                  succeeded.add({
                    'userId': map['userId'] as String,
                    'eventId': map['eventId'] as String,
                  });
                }
              }
              raw.replyTo.send(succeeded);
              break;
          }
        } catch (e) {
          // Log any unexpected isolate errors
          await ErrorLogRepository()
              .logError('isolate_sync', e.runtimeType.toString());
          raw.replyTo.send(<Map<String, String>>[]);
        }
      }
    });
  }

  /// Post a single draft bet; returns true if the backend accepted it.
  static Future<bool> _sendDraft(Map<String, dynamic> d) async {
    //final url = Uri.parse('http://localhost:8000/api/bets');
    final url = Uri.parse('${Config.apiBaseUrl}/api/bets');
    final body = jsonEncode({
      'userId': d['userId'],
      'eventId': d['eventId'],
      'stake': d['stake'],
      'odds': d['odds'],
      'team': d['team'],
    });
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 201) {
        return true;
      } else {
        // Log unexpected status codes
        await ErrorLogRepository()
            .logError('/api/bets', 'BadStatus${res.statusCode}');
        return false;
      }
    } catch (e) {
      // Log connectivity or other HTTP failures
      await ErrorLogRepository()
          .logError('/api/bets', e.runtimeType.toString());
      return false;
    }
  }
}
