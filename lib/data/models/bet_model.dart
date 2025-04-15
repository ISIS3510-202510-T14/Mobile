// lib/data/models/bet_model.dart
class BetModel {
  final String userId;
  final String eventId;
  final double stake;
  final double? odds; // Permite null
  final String team;

  BetModel({
    required this.userId,
    required this.eventId,
    required this.stake,
    this.odds,
    required this.team,
  });

  // Creación del objeto a partir de un Map (por ejemplo, leído desde la DB)
  factory BetModel.fromJson(Map<String, dynamic> json) {
    return BetModel(
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      stake: json['stake'] as double,
      odds: json['odds'] != null ? (json['odds'] as num).toDouble() : null,
      team: json['team'] as String,
    );
  }

  // Convertir el objeto a Map para insertarlo en la DB
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'stake': stake,
      'odds': odds,
      'team': team,
    };
  }
}
