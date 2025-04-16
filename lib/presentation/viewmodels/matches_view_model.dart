import 'dart:convert';
import 'package:campus_picks/data/models/location_model.dart';
import 'package:campus_picks/data/repositories/auth_repository.dart';
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
          logoTeamA: 'https://www.ingebook.com/ib/pimg/Ingebook/00100_0000002134_UNIANDES_Transparente.png',
          logoTeamB: 'https://d1yjjnpx0p53s8.cloudfront.net/styles/logo-thumbnail/s3/0017/5608/brand.gif?itok=Xj1Bk5oB',
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
          logoTeamA: 'https://www.ingebook.com/ib/pimg/Ingebook/00100_0000002134_UNIANDES_Transparente.png',
          logoTeamB: 'https://d1yjjnpx0p53s8.cloudfront.net/styles/logo-thumbnail/s3/0017/5608/brand.gif?itok=Xj1Bk5oB',
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
          logoTeamA: 'https://www.ingebook.com/ib/pimg/Ingebook/00100_0000002134_UNIANDES_Transparente.png',
          logoTeamB: 'https://d1yjjnpx0p53s8.cloudfront.net/styles/logo-thumbnail/s3/0017/5608/brand.gif?itok=Xj1Bk5oB',
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
    final uri = Uri.http('localhost:8000', '/api/location');

    // Enviar la petición POST
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    print("Respuesta del servidor: ${response.statusCode} - ${response.body}");
  } catch (e) {
    print("Error al enviar la ubicación: $e");
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
