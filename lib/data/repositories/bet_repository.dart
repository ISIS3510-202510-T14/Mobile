// lib/data/repositories/bet_repository.dart
//
// v2 ‑ 2025‑04‑18
// • replaceAllForUser() now runs inside a transaction **and**
//   uses ConflictAlgorithm.replace so any duplicate (userId,eventId)
//   rows coming from the backend no longer abort the whole batch.

import 'package:sqflite/sqflite.dart';          // <-- NEW
import '../models/bet_model.dart';
import '../services/database_helper.dart';

class BetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ──────────────────────────────────────────────────────────────────────
  //  CRUD (single‑row helpers)
  // ──────────────────────────────────────────────────────────────────────
  Future<int> insertBet(BetModel bet) async {
    return _dbHelper.insertBet(bet);
  }

  Future<BetModel?> getBet(String userId, String eventId) async {
    return _dbHelper.getBet(userId, eventId);
  }

  Future<List<BetModel>> getAllBets() async {
    return _dbHelper.getAllBets();
  }

  Future<List<BetModel>> getBetsForUser(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'bets',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return res.map((row) => BetModel.fromJson(row)).toList();
  }

  Future<int> updateBet(BetModel bet) async {
    return _dbHelper.updateBet(bet);
  }

  Future<int> deleteBet(String userId, String eventId) async {
    return _dbHelper.deleteBet(userId, eventId);
  }

    /// Returns all bets saved as drafts in local storage
    Future<List<BetModel>> getDraftBets() async {
      final rows = await _dbHelper.getDraftRows();
      return rows.map((json) => BetModel.fromJson(json)).toList();
    }

    /// Marks the given draft bet as synced (clears isDraft flag)
    Future<void> markBetAsSynced(BetModel bet) async {
      await _dbHelper.markBetSynced(bet.userId, bet.eventId);
    }

    /// Alias for bulk fetching drafts for syncing
    Future<List<BetModel>> bulkSyncDrafts() => getDraftBets();

  // ──────────────────────────────────────────────────────────────────────
  //  BULK SYNC  – called by UserBetsViewModel after a /api/bets/history
  // ──────────────────────────────────────────────────────────────────────
  Future<void> replaceAllForUser(String userId, List<BetModel> fresh) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1) wipe previous bets for this user
      await txn.delete('bets', where: 'userId = ?', whereArgs: [userId]);

      // 2) nothing new? we’re done
      if (fresh.isEmpty) return;

      // 3) insert – always stamping the correct userId
      final batch = txn.batch();
      for (final b in fresh) {
        final map = b.toJson()
          ..['userId'] = userId;                // ←—— inject the real UID
        batch.insert(
          'bets',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}
