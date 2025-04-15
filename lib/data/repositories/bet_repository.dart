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

  Future<int> updateBet(BetModel bet) async {
    return await _dbHelper.updateBet(bet);
  }

  Future<int> deleteBet(String userId, String eventId) async {
    return await _dbHelper.deleteBet(userId, eventId);
  }
}
