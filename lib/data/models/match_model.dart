import 'location_model.dart';
class MatchModel {
  final String eventId;
  final String acidEventId;
  final String name;
  final String sport;
  final LocationModel location;
  final DateTime startTime;
  final String status;
  final String providerId;
  final String homeTeam;
  final String awayTeam;
  // Optional fields with defaults
  final String tournament;
  final String logoTeamA;
  final String logoTeamB;
  final int? scoreTeamA;
  final int? scoreTeamB;
  final int? minute;
  final DateTime dateTime = DateTime.now();

  MatchModel({
    required this.eventId,
    required this.acidEventId,
    required this.name,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.status,
    required this.providerId,
    required this.homeTeam,
    required this.awayTeam,
    this.tournament = 'Default Tournament',
    this.logoTeamA = 'assets/images/default.png',
    this.logoTeamB = 'assets/images/default.png',
    this.scoreTeamA,
    this.scoreTeamB,
    this.minute,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    
    return MatchModel(
      eventId: json['eventId'] ?? '',
      acidEventId: json['acidEventId'] ?? '',
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      // Parseamos la ubicación usando LocationModel
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : LocationModel(lat: 0, lng: 0),
      startTime: DateTime.parse(json['startTime']),
      status: json['status'] ?? '',
      providerId: json['providerId'] ?? '',
      // Según tu JSON de ejemplo, los nombres de los equipos vienen en "team1" y "team2"
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      // Los demás campos se mantienen con sus valores por defecto o asignados
      // Si en el futuro el API envía otros datos, podrías ajustarlos
    );
  }


}
