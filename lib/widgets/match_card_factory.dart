// lib/widgets/match_card_factory.dart
import 'package:flutter/material.dart';
import '../data/models/match_model.dart';
import 'match_card.dart';
import 'live_match_card.dart';
//import 'upcoming_match_card.dart';
import 'finished_match_card.dart';

class MatchCardFactory {
  /// Creates a MatchCard widget based on the match status.
  static Widget createMatchCard(MatchModel match) {
    switch (match.status) {
      case 'Live':
        return LiveMatchCard(match: match);
      case 'Upcoming':
        return MatchCard(match: match);
      case 'Finished':
        return FinishedMatchCard(match: match);
      default:
        return MatchCard(match: match);
    }
  }
}
