import "../services/database_helper.dart";
import '../models/match_model.dart';

class MatchRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<MatchModel>> fetchMatches() async {
    return await _dbHelper.getAllMatches();
  }

  Future<void> addMatch(MatchModel match) async {
    await _dbHelper.insertMatch(match);
  }

  Future<void> updateMatch(MatchModel match) async {
    await _dbHelper.updateMatch(match);
  }

  Future<void> removeMatch(String eventId) async {
    await _dbHelper.deleteMatch(eventId);
  }

  Future<void> syncMatches(List<MatchModel> freshFromApi) async {
  await _dbHelper.insertMatchesBatch(freshFromApi);
}


}
