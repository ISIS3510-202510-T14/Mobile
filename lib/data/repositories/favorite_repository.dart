// lib/data/repositories/favorite_repository.dart
import '../services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../models/match_model.dart';


class FavoriteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Insertar un favorito
  Future<int> insertFavorite(String userId, String eventId) async {
    final db = await _dbHelper.database;

    return await db.insert(
      'favorites',
      {'userId': userId, 'eventId': eventId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Eliminar un favorito
  Future<int> deleteFavorite(String userId, String eventId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'favorites',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
  }

  // Verificar si un partido está marcado como favorito para un usuario
  Future<bool> isFavorite(String userId, String eventId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'favorites',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
    return res.isNotEmpty;
  }
  
  // Opcional: Obtener todos los favorites de un usuario
  Future<List<String>> getFavoritesForUser(String userId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return res.map((row) => row['eventId'] as String).toList();
  }


  Future<List<MatchModel>> getFavoriteMatches(String userId) async {
  final db = await _dbHelper.database;
  // Se hace un join entre la tabla favorites y matches usando eventId.
  final res = await db.rawQuery('''
    SELECT m.*
    FROM matches m
    INNER JOIN favorites f ON m.eventId = f.eventId
    WHERE f.userId = ?
  ''', [userId]);
  
  // Mapear cada fila al objeto MatchModel, asegurándose de convertir el row con _convertDbRowToMatchJson().
  return res.map((row) => MatchModel.fromJson(_convertDbRowToMatchJson(row))).toList();
}

// Si _convertDbRowToMatchJson está definido en DatabaseHelper, puedes moverlo a un archivo utilitario o
// volver a definirlo aquí:
Map<String, dynamic> _convertDbRowToMatchJson(Map<String, dynamic> row) {
  final mutableRow = Map<String, dynamic>.from(row);
  mutableRow['location'] = {
    'lat': mutableRow['locationLat'],
    'lng': mutableRow['locationLng'],
  };
  return mutableRow;
}




}
