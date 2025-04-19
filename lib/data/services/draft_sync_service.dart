// lib/data/services/draft_sync_service.dart
// NEW – global background synchroniser for offline draft bets
// -----------------------------------------------------------------------------
//  • Listens to ConnectivityNotifier.
//  • When the app goes online, reads all draft rows (isDraft = 1) and
//    re‑POSTs them to the backend.
//  • On every 201 OK it immediately marks the row as synced.
//  • Exposes a ValueNotifier<String?> so the UI can show SnackBars/toasts if
//    desired (optional – nothing in the core flow depends on it).
// -----------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../repositories/bet_repository.dart';
import '../models/bet_model.dart';
import 'connectivity_service.dart';

class DraftSyncService extends ChangeNotifier {
  final ConnectivityNotifier connectivity;
  final BetRepository _repo = BetRepository();

  /// Optional: emit user‑visible messages like “Syncing…” or “Drafts synced”.
  final ValueNotifier<String?> syncStatus = ValueNotifier<String?>(null);

  DraftSyncService({required this.connectivity}) {
    // Listen for connectivity changes.
    connectivity.addListener(_onConnectivityChanged);

    // If we start online, kick off an initial sync.
    if (connectivity.isOnline) _syncPendingDrafts();
  }

  @override
  void dispose() {
    connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  /*──────────────────────── private helpers ────────────────────────*/
  void _onConnectivityChanged() {
    if (connectivity.isOnline) _syncPendingDrafts();
  }

  Future<void> _syncPendingDrafts() async {
    final drafts = await _repo.bulkSyncDrafts();
    if (drafts.isEmpty) return;

    syncStatus.value = 'Syncing draft bets…';

    for (final d in drafts) {
      final ok = await _sendDraft(d);
      if (ok) {
        await _repo.markBetAsSynced(d);
      }
    }

    syncStatus.value = 'Draft bets synced';
    notifyListeners();
  }

  Future<bool> _sendDraft(BetModel d) async {
    final url = Uri.parse('http://localhost:8000/api/bets');
    final body = jsonEncode({
      "userId": d.userId,
      "eventId": d.eventId, // use the draft's own eventId
      "stake" : d.stake,
      "odds"  : d.odds,
      "team"  : d.team,
    });

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
