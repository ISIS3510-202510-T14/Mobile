import 'dart:convert';
import 'package:campus_picks/data/models/location_model.dart';
import 'package:campus_picks/data/repositories/auth_repository.dart';
import 'package:campus_picks/data/repositories/error_log_repository.dart';
import 'package:campus_picks/data/repositories/favorite_repository.dart';
import 'package:campus_picks/data/repositories/match_repository.dart';
import 'package:campus_picks/data/services/auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/match_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '/main.dart' show flutterLocalNotificationsPlugin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/metrics_management.dart' as metrics_management;
import 'package:campus_picks/src/config.dart';




class MatchesViewModel extends ChangeNotifier {
  List<MatchModel> liveMatches = [];
  List<MatchModel> upcomingMatches = [];
  List<MatchModel> finishedMatches = [];
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final MatchRepository _matchRepository = MatchRepository();
  final ConnectivityNotifier connectivityNotifier;

  MatchesViewModel({required this.connectivityNotifier});
  
  // Métodos que usan connectivityNotifier...
  

  /// Fetches events from the API endpoint using a GET request.
  /// Optional query parameters: [sport] and [startDate].
  Future<void> fetchMatches({String? sport, DateTime? startDate}) async {
  print('[fetchMatches] Iniciando método...');

  final endpoint = '/api/events';
  final queryParameters = {
    if (sport != null) 'sport': sport,
    if (startDate != null) 'startDate': startDate.toIso8601String(),
  };


    // Usar Uri.http para HTTP (no https) en localhost
    
   //final uri = Uri.http('localhost:8000', '/api/events', queryParameters);
   // Construir la URI usando tu base definida en Config
    final uri = Uri
        .parse('${Config.apiBaseUrl}/api/events')
        .replace(queryParameters: queryParameters);
        print('[fetchMatches] URI construido: $uri');

  final startTime = DateTime.now();
  int duration = 0;
  int? statusCode;
  bool success = false;
  String? error;

  try {
    final response = await http.get(uri);
    duration = DateTime.now().difference(startTime).inMilliseconds;
    statusCode = response.statusCode;

    print('[fetchMatches] Código de estado: ${response.statusCode}');
    print('[fetchMatches] Body de la respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!data.containsKey('events')) {
        throw Exception('La respuesta no contiene "events".');
      }

      final events = data['events'] as List;
      List<MatchModel> matches = events.map((e) {
        return MatchModel.fromJson(e as Map<String, dynamic>);
      }).toList();

      liveMatches = matches.where((m) => m.status.toLowerCase() == 'live').toList();
      upcomingMatches = matches.where((m) => m.status.toLowerCase() == 'upcoming').toList();
      finishedMatches = matches.where((m) => m.status.toLowerCase() == 'finished').toList();

      success = true;
      notifyListeners();
    } else {
      error = 'BadStatus${response.statusCode}';
      await ErrorLogRepository().logError(endpoint, error);
      throw Exception('Failed to fetch matches: ${response.statusCode}');
    }
  } catch (e) {
    duration = DateTime.now().difference(startTime).inMilliseconds;
    error = e.runtimeType.toString();
    await ErrorLogRepository().logError(endpoint, error);

    try {
      Position userPosition = await _determinePosition();
      final locationUser = LocationModel(
        lat: userPosition.latitude,
        lng: userPosition.longitude,
      );

      final fallbackMatches = _generateFallbackMatches(locationUser);
      _assignMatchesByStatus(fallbackMatches);
    } catch (_) {
      final fallbackLocation = LocationModel(lat: 4.6033508, lng: -74.0672136);
      final fallbackMatches = _generateFallbackMatches(fallbackLocation);
      _assignMatchesByStatus(fallbackMatches);
    }

    notifyListeners();
    rethrow;
  } finally {
    await metrics_management.logApiMetric(
      endpoint: endpoint,
      duration: duration,
      statusCode: statusCode,
      success: success,
      error: error,
    );
  }
}

void _assignMatchesByStatus(List<MatchModel> matches) {
  liveMatches = matches.where((m) => m.status.toLowerCase() == 'live').toList();
  upcomingMatches = matches.where((m) => m.status.toLowerCase() == 'upcoming').toList();
  finishedMatches = matches.where((m) => m.status.toLowerCase() == 'finished').toList();
}

List<MatchModel> _generateFallbackMatches(LocationModel location) {
  return [
    MatchModel(
      eventId: 'fallback-1',
      acidEventId: 'fallback-acid1',
      name: 'Fallback Match 1',
      sport: 'soccer',
      location: location,
      startTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'upcoming',
      providerId: 'fallback-provider',
      homeTeam: 'Los Andes',
      awayTeam: 'La Sabana',
      oddsA: 1.50,
      oddsB: 2.20,
      logoTeamA: 'assets/images/team_alpha.png',
      logoTeamB: 'assets/images/team_beta.png',
    ),
    MatchModel(
      eventId: 'fallback-2',
      acidEventId: 'fallback-acid2',
      name: 'Fallback Match 2',
      sport: 'football',
      location: location,
      startTime: DateTime.now(),
      status: 'live',
      providerId: 'fallback-provider',
      homeTeam: 'Los Andes',
      awayTeam: 'La Sabana',
      oddsA: 1.80,
      oddsB: 2.05,
      logoTeamA: 'assets/images/team_alpha.png',
      logoTeamB: 'assets/images/team_beta.png',
    ),
    MatchModel(
      eventId: 'fallback-3',
      acidEventId: 'fallback-acid3',
      name: 'Fallback Match 3',
      sport: 'basketball',
      location: location,
      startTime: DateTime.now(),
      status: 'finished',
      providerId: 'fallback-provider',
      homeTeam: 'Los Andes',
      awayTeam: 'La Sabana',
      oddsA: 1.25,
      oddsB: 3.10,
      logoTeamA: 'assets/images/team_alpha.png',
      logoTeamB: 'assets/images/team_beta.png',
    ),
  ];
}



  Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if GPS service is enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // Check permissions.
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  // Return the current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

Future<void> checkProximityAndNotify() async {
  try {
    // Get the user's current position
    Position userPosition = await _determinePosition();
    final double userLat = userPosition.latitude;
    final double userLng = userPosition.longitude;

    // Date formatter (if needed for the notification message)
   // final DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    // Check upcoming events (assumed status: "upcoming")
    for (final match in upcomingMatches) {
      // Calculate distance in meters between user and event location
      double distanceMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        match.location.lat,
        match.location.lng,
      );

      print('User lat and lng: $userLat, $userLng');
      print('Match location lat and lng: ${match.location.lat}, ${match.location.lng}');
      double distanceKm = distanceMeters / 1000.0;

      if (distanceKm <= 1.0) {
        await _showNotification(
          title: 'Upcoming Event Nearby',
          body:
              '${match.homeTeam} vs ${match.awayTeam} at ${match.startTime.day}/${match.startTime.month} ${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}\nDistance: ${distanceKm.toStringAsFixed(2)} km',
        );
      }
    }

    // Check live events (assumed status: "live")
    for (final match in liveMatches) {
      double distanceMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        match.location.lat,
        match.location.lng,
      );
      double distanceKm = distanceMeters / 1000.0;

      if (distanceKm <= 1.0) {
        if (distanceKm <= 0.1) {
         await _showLiveMatchNotification(
            match: match,
            distanceInKm: distanceKm,
            withBetNow: true,
          );
          // Complete


        } else {
          // Otherwise, a basic live event notification
          await _showLiveMatchNotification(
            match: match,
            distanceInKm: distanceKm,
            withBetNow: false,
          );
        }
      }
    }
  } catch (e) {
    print('Error in checkProximityAndNotify: $e');
  }
}

/// Basic notification without actions.
Future<void> _showNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'basic_channel_id',
    'Basic Notifications',
    channelDescription: 'Notifications for nearby events',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(0, title, body, details);
}

/// Notification for live events; if withBetNow is true, includes a "Bet Now" action.
Future<void> _showLiveMatchNotification({
  required MatchModel match,
  required double distanceInKm,
  required bool withBetNow,
}) async {
  AndroidNotificationDetails androidDetails;
  if (withBetNow) {
    androidDetails = const AndroidNotificationDetails(
      'live_channel',
      'Live Events',
      channelDescription: 'Notifications for live events near you',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('bet_now_action', 'Bet Now', showsUserInterface: true),
      ],
    );
  } else {
    androidDetails = const AndroidNotificationDetails(
      'live_channel',
      'Live Events',
      channelDescription: 'Notifications for live events near you',
      importance: Importance.max,
      priority: Priority.high,
    );
  }
  NotificationDetails details = NotificationDetails(android: androidDetails);

  AuthRepository authRepository = AuthRepository();
  String? userUID =  authService.value.currentUser?.uid;
  

  final payloadMap = {
    'match': match.toJson(), // Serializa todo el objeto MatchModel
    'userUID': userUID,      // Incluye el uid del usuario
  };

  print('Payload notification: $payloadMap'); // Debugging line

  await flutterLocalNotificationsPlugin.show(
    withBetNow ? 1 : 2, // Use different notification IDs
    withBetNow ? 'Live Event - Bet Now!' : 'Live Event Nearby',
    '${match.homeTeam} vs ${match.awayTeam}\nDistance: ${distanceInKm.toStringAsFixed(2)} km \n coords: ${match.location.lat}, ${match.location.lng} \n location: La caneca',
    details,
    payload: jsonEncode(payloadMap), // Serializa el payload
    //payload: withBetNow ? 'bet_now_action' : null,
  );
}
  
Future<void> sendUserLocation() async {
  final stopwatch = Stopwatch()..start();
  int? statusCode;
  bool success = false;
  String? error;

  try {
    // Obtener la posición actual
    Position userPosition = await _determinePosition();

    // Obtener el usuario autenticado y su uid
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No hay usuario autenticado.');
      return;
    }
    String uid = user.uid;

    // Crear el timestamp actual en formato ISO 8601 (UTC)
    String timestamp = DateTime.now().toUtc().toIso8601String();

    // Construir el payload para la petición POST
    Map<String, dynamic> payload = {
      "userId": uid,
      "lat": userPosition.latitude,
      "lng": userPosition.longitude,
      "timestamp": timestamp,
    };

    // Construir la URL de la API (en este caso, se usa http y localhost)
    //final uri = Uri.http('localhost:8000', '/api/location');
    final uri = Uri.parse('${Config.apiBaseUrl}/api/location');

    // Enviar la petición POST
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    stopwatch.stop();
    statusCode = response.statusCode;
    success = response.statusCode == 200;

    if (!success) {
      error = response.body;
      await ErrorLogRepository().logError(
        '/api/location',
        'BadStatus$response.statusCode',
      );
    }

    print("Respuesta del servidor: ${response.statusCode} - ${response.body}");
  } catch (e) {
    stopwatch.stop();
    error = e.toString();
    await ErrorLogRepository().logError(
      '/api/location',
      e.runtimeType.toString(),
    );
    print("Error al enviar la ubicación: $e");
  } finally {
    await metrics_management.logApiMetric(
      endpoint: '/api/location',
      duration: stopwatch.elapsedMilliseconds,
      statusCode: statusCode,
      success: success,
      error: error,
    );
  }
}



Future<void> fetchMatchesWithFavorites({
  String? sport,
  DateTime? startDate,
}) async {
  final bool offline =
      connectivityNotifier.connectionStatus == ConnectivityResult.none;

  List<MatchModel> allMatches;

  if (offline) {
    // 1) ***SIN RED → solo BD local***
    allMatches = await _matchRepository.fetchMatches();
  } else {
    // 2) ***CON RED → backend + sincronizar BD local***
    try {
      await fetchMatches(sport: sport, startDate: startDate);      // baja los datos
      allMatches = [...liveMatches, ...upcomingMatches, ...finishedMatches];

      // // guarda/actualiza cada partido en SQLite
      // for (final m in allMatches) {
      //   await _matchRepository.addMatch(m); // usa ON CONFLICT REPLACE en DBHelper
      // }
      await _matchRepository.syncMatches(allMatches); // usa ON CONFLICT REPLACE en DBHelper
    } catch (_) {
      // Si la petición falló (servidor caído, timeout, etc.) leo local
      allMatches = await _matchRepository.fetchMatches();
    }
  }

  // ---------- marcar favoritos ----------
  final user = FirebaseAuth.instance.currentUser;
  final favIds = user == null
      ? <String>[]
      : await _favoriteRepository.getFavoritesForUser(user.uid);

  for (var m in allMatches) {
    m.isFavorite = favIds.contains(m.eventId);
  }

  //final favoriteMatches = await _favoriteRepository.getFavoriteMatches(user!.uid);




  // ---------- repartir por status ----------
  liveMatches     = allMatches.where((m) => m.status == 'live').toList();
  upcomingMatches = allMatches.where((m) => m.status == 'upcoming').toList();
  finishedMatches = allMatches.where((m) => m.status == 'finished').toList();

  notifyListeners();
}



Future<void> toggleFavorite(String eventId, bool isFavorite, MatchModel match) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // Manejar caso sin usuario
  try {
    if (isFavorite) {
      // Persiste el partido como favorito (todos sus datos)
      await _favoriteRepository.insertFavorite(user.uid, match.eventId);
      // Aquí puedes guardar el objeto completo en la base de datos local si es necesario
      await _matchRepository.addMatch(match); // Asumiendo que tienes un método para insertar el partido completo
      print( "Partido favorito agregado: ${match.eventId}");
    } else {
      // Elimina el favorito (por ejemplo, usando el eventId)
      await _favoriteRepository.deleteFavorite(user.uid, eventId);
    }
    // Actualiza la propiedad isFavorite en todas las listas donde aparezca el partido
    for (final list in [liveMatches, upcomingMatches, finishedMatches]) {
      for (final m in list) {
        if (m.eventId == eventId) {
          m.isFavorite = isFavorite;
        }
      }
    }
    notifyListeners();
  } catch (e) {
    print("Error toggling favorite for $eventId: $e");
  }
}






}
