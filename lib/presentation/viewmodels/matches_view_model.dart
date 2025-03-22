import 'dart:convert';
import 'package:campus_picks/data/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/match_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '/main.dart' show flutterLocalNotificationsPlugin;


class MatchesViewModel extends ChangeNotifier {
  List<MatchModel> liveMatches = [];
  List<MatchModel> upcomingMatches = [];
  List<MatchModel> finishedMatches = [];

  /// Fetches events from the API endpoint using a GET request.
  /// Optional query parameters: [sport] and [startDate].
  Future<void> fetchMatches({String? sport, DateTime? startDate}) async {
  print('[fetchMatches] Iniciando método...');

  // Construir parámetros de consulta
  final queryParameters = {
    if (sport != null) 'sport': sport,
    if (startDate != null) 'startDate': startDate.toIso8601String(),
  };
  print('[fetchMatches] Parámetros de consulta: $queryParameters');

  // Usar Uri.http para HTTP (no https) en localhost
  final uri = Uri.http('localhost:8000', '/api/events', queryParameters);
  print('[fetchMatches] URI construido: $uri');

  try {
    final response = await http.get(uri);
    print('[fetchMatches] Código de estado: ${response.statusCode}');
    print('[fetchMatches] Body de la respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[fetchMatches] JSON decodificado: $data');

      if (!data.containsKey('events')) {
        print('[fetchMatches] La clave "events" no existe en la respuesta');
        throw Exception('La respuesta no contiene "events".');
      }

      final events = data['events'] as List;
      print('[fetchMatches] Cantidad de eventos: ${events.length}');

      // Usamos el factory del modelo para parsear cada evento
      List<MatchModel> matches = events.map((e) {
        print('[fetchMatches] Procesando evento: $e');
        final match = MatchModel.fromJson(e);
        print('[fetchMatches] Location del match: ${match.location}');
        return match;
      }).toList();


      // Separar según status (asegúrate de que los status estén en minúsculas en el API)
      liveMatches = matches.where((m) => m.status.toLowerCase() == 'live').toList();
      upcomingMatches = matches.where((m) => m.status.toLowerCase() == 'upcoming').toList();
      finishedMatches = matches.where((m) => m.status.toLowerCase() == 'finished').toList();

      print('[fetchMatches] Petición exitosa. Notificando listeners...');
      notifyListeners();
    } else {
      print('[fetchMatches] Respuesta != 200. Lanzando excepción...');
      throw Exception('Failed to fetch matches');
    }
  } catch (e, s) {
    LocationModel locationCityU = LocationModel(lat: 4.603350783618252, lng: -74.06721356441832);
    Position userPosition = await _determinePosition();
    LocationModel locationUser = LocationModel(lat: userPosition.latitude, lng: userPosition.longitude);
    
     final fallbackMatches = <MatchModel>[
        MatchModel(
          eventId: 'fallback-1',
          acidEventId: 'fallback-acid1',
          name: 'Fallback Match 1',
          sport: 'soccer',
          location: locationUser,
          startTime: DateTime.now().add(const Duration(hours: 2)),
          status: 'upcoming',
          logoTeamA: 'assets/images/uniandes.png',
          logoTeamB: 'assets/images/sabana.png',
          providerId: 'fallback-provider',
          homeTeam: 'Los Andes',
          awayTeam: 'La Sabana',
        ),
        MatchModel(
          eventId: 'fallback-2',
          acidEventId: 'fallback-acid2',
          name: 'Fallback Match 2',
          sport: 'football',
          location: locationUser,
          startTime: DateTime.now(),
          status: 'live',
          logoTeamA: 'assets/images/uniandes.png',
          logoTeamB: 'assets/images/sabana.png',
          providerId: 'fallback-provider',
          homeTeam: 'Los Andes',
          awayTeam: 'La Sabana',
        ),
         MatchModel(
          eventId: 'fallback-2',
          acidEventId: 'fallback-acid2',
          name: 'Fallback Match 2',
          sport: 'basketball',
          location: locationUser,
          startTime: DateTime.now(),
          status: 'finished',
          logoTeamA: 'assets/images/uniandes.png',
          logoTeamB: 'assets/images/sabana.png',
          providerId: 'fallback-provider',
          homeTeam: 'Los Andes',
          awayTeam: 'La Sabana',
        ),
      ];

      liveMatches = fallbackMatches.where((m) => m.status.toLowerCase() == 'live').toList();
      upcomingMatches = fallbackMatches.where((m) => m.status.toLowerCase() == 'upcoming').toList();
      finishedMatches = fallbackMatches.where((m) => m.status.toLowerCase() == 'finished').toList();

      notifyListeners();
    rethrow;
  }
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
        AndroidNotificationAction('bet_now_action', 'Bet Now'),
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

  await flutterLocalNotificationsPlugin.show(
    withBetNow ? 1 : 2, // Use different notification IDs
    withBetNow ? 'Live Event - Bet Now!' : 'Live Event Nearby',
    '${match.homeTeam} vs ${match.awayTeam}\nDistance: ${distanceInKm.toStringAsFixed(2)} km \n coords: ${match.location.lat}, ${match.location.lng} \n location: La caneca',
    details,
    //payload: withBetNow ? 'bet_now_action' : null,
  );
}
  

}
