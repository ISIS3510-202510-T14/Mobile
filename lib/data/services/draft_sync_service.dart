import 'package:flutter/foundation.dart';

import '../repositories/bet_repository.dart';
import 'connectivity_service.dart';
import 'background_sync_service.dart';

/// Watches connectivity and, when online, delegates
/// draft‑bet synchronization to the background isolate
/// while keeping all SQLite writes in the main isolate.
class DraftSyncService extends ChangeNotifier {
  final ConnectivityNotifier connectivity;
  final BetRepository _repo = BetRepository();

  /// Emits user‑visible messages like “Syncing…” or “Drafts synced”.
  final ValueNotifier<String?> syncStatus = ValueNotifier<String?>(null);

  DraftSyncService({required this.connectivity}) {
    connectivity.addListener(_onConnectivityChanged);
    if (connectivity.isOnline) _scheduleSync();
  }

  @override
  void dispose() {
    connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (connectivity.isOnline) _scheduleSync();
  }

  /// Loads locally‐saved drafts, delegates the POSTs to the isolate,
  /// then marks each successfully‐posted draft as synced in SQLite.
  Future<void> _scheduleSync() async {
    // 1) load all drafts from local SQLite
    final drafts = await _repo.bulkSyncDrafts();
    if (drafts.isEmpty) return;

    // 2) notify UI
    syncStatus.value = 'Syncing draft bets…';

    // 3) serialize and send to isolate
    final jsonList = drafts.map((d) => d.toJson()).toList();
    final succeeded = await BackgroundSyncService.syncDrafts(jsonList);

    // 4) for each successful POST, reload the draft model and mark it synced
    for (final info in succeeded) {
      final userId = info['userId']!;
      final eventId = info['eventId']!;
      final draft = await _repo.getBet(userId, eventId);
      if (draft != null) {
        await _repo.markBetAsSynced(draft);
      }
    }

    // 5) final UI update
    syncStatus.value = 'Draft bets synced';
    notifyListeners();
  }
}
