import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/match_model.dart';

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
    print('[fetchMatches] Ocurrió un error: $e');
    print('[fetchMatches] StackTrace: $s');
    rethrow;
  }
}

}
