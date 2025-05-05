import '../models/recommended_bet_model.dart';
import '../services/database_helper.dart';

class RecommendedBetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertRecommendedBet(RecommendedBet bet) async {
    return await _dbHelper.insertRecommendedBet(bet);
  }

  Future<RecommendedBet?> getRecommendedBet(String recommendationId) async {
    return await _dbHelper.getRecommendedBet(recommendationId);
  }

  Future<List<RecommendedBet>> getAllRecommendedBets() async {
    return await _dbHelper.getAllRecommendedBets();
  }

  Future<int> updateRecommendedBet(RecommendedBet bet) async {
    return await _dbHelper.updateRecommendedBet(bet);
  }

  Future<int> deleteRecommendedBet(String recommendationId) async {
    return await _dbHelper.deleteRecommendedBet(recommendationId);
  }
}
