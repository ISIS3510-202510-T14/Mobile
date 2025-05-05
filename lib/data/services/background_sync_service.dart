// lib/data/services/background_sync_service.dart

import 'package:campus_picks/data/services/isolate_manager.dart';

/// Façade for enqueuing draft synchronization in the background isolate.
class BackgroundSyncService {
  /// Enqueue a syncDrafts task on the background isolate, passing serialized drafts.
  /// Returns a list of maps `{ 'userId': ..., 'eventId': ... }` for each draft that succeeded.
  static Future<List<Map<String, String>>> syncDrafts(List<Map<String, dynamic>> draftsJson) {
    return IsolateManager().enqueue(TaskType.syncDrafts, draftsJson)
        .then((res) => (res as List).cast<Map<String, String>>());
  }
}
