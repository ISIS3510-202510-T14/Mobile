
// Modelo para la apuesta recomendada
class RecommendedBet {
  final String recommendationId;
  final String eventId;
  final String betType;
  final String description;
  final DateTime createdAt;

  RecommendedBet({
    required this.recommendationId,
    required this.eventId,
    required this.betType,
    required this.description,
    required this.createdAt,
  });

  factory RecommendedBet.fromJson(Map<String, dynamic> json) {
    return RecommendedBet(
      recommendationId: json['recommendationId'] ?? json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      betType: json['betType'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendationId': recommendationId,
      'eventId': eventId,
      'betType': betType,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }


}