import 'location_model.dart';
import 'dart:math';

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
  final String venue;
  
  // Nuevo campo opcional para marcar como favorito
  bool isFavorite;

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
    this.logoTeamA = 'assets/images/team_alpha.png',
    this.logoTeamB = 'assets/images/team_beta.png',
    this.scoreTeamA = 0,
    this.scoreTeamB = 0,
    this.minute,
    this.venue = 'La caneca',
    this.isFavorite = false, // Valor predeterminado false
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Lista de venues por defecto
    final defaultVenues = [
      "La caneca",
      "La Javeriana Polideportivo",
      "Estadio Metropolitano",
      "El Coliseo",
      "Arena Central"
    ];
    String venue;
    if (json.containsKey('venue') &&
        json['venue'] != null &&
        json['venue'].toString().isNotEmpty) {
      venue = json['venue'];
    } else {
      venue = defaultVenues[Random().nextInt(defaultVenues.length)];
    }

    return MatchModel(
      eventId: json['eventId'] ?? '',
      acidEventId: json['acidEventId'] ?? '',
      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : LocationModel(lat: 0, lng: 0),
      startTime: DateTime.parse(json['startTime']),
      status: json['status'] ?? '',
      providerId: json['providerId'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      scoreTeamA: json["home_score"] ?? 0,
      scoreTeamB: json["away_score"] ?? 0,
      venue: venue,
      // Se lee isFavorite si viene, sino se asigna false
      isFavorite: json.containsKey('isFavorite') ? json['isFavorite'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'acidEventId': acidEventId,
      'name': name,
      'sport': sport,
      'location': location.toJson(), // Si en backend se espera un objeto anidado, se deja así
      'startTime': startTime.toIso8601String(),
      'status': status,
      'providerId': providerId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'tournament': tournament,
      'logoTeamA': logoTeamA,
      'logoTeamB': logoTeamB,
      'home_score': scoreTeamA,
      'away_score': scoreTeamB,
      'minute': minute,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'isFavorite': isFavorite, // Se incluye en el map para persistirlo localmente si se desea
    };
  }
}
