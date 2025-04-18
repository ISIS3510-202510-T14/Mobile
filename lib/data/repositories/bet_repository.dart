// lib/data/repositories/bet_repository.dart
import '../models/bet_model.dart';
import '../services/database_helper.dart';

class BetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertBet(BetModel bet) async {
    return await _dbHelper.insertBet(bet);
  }

  Future<BetModel?> getBet(String userId, String eventId) async {
    return await _dbHelper.getBet(userId, eventId);
  }

  Future<List<BetModel>> getAllBets() async {
    return await _dbHelper.getAllBets();
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
    return await _dbHelper.updateBet(bet);
  }

  Future<int> deleteBet(String userId, String eventId) async {
    return await _dbHelper.deleteBet(userId, eventId);
  }
}
