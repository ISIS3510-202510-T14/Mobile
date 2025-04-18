import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/match_model.dart';
import '../models/bet_model.dart';
import '../models/recommended_bet_model.dart';

class DatabaseHelper {
  // Patrón Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter para obtener la base de datos (inicializa si es necesario)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('matches.db');
    return _database!;
  }

  // Inicializa la base de datos indicando la ruta y el nombre del archivo
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE matches ADD COLUMN oddsA REAL DEFAULT 1.0;');
          await db.execute('ALTER TABLE matches ADD COLUMN oddsB REAL DEFAULT 1.0;');
        }
      },
    );
  }

  // Método para crear las tablas
  Future _createDB(Database db, int version) async {
    // Considerando los atributos de MatchModel, definimos una tabla "matches".
    // En este ejemplo, para el campo 'location' usamos dos columnas: locationLat y locationLng.
    const matchTable = '''
      CREATE TABLE matches (
        eventId TEXT PRIMARY KEY,
        acidEventId TEXT,
        name TEXT,
        sport TEXT,
        locationLat REAL,
        locationLng REAL,
        startTime TEXT,
        status TEXT,
        providerId TEXT,
        homeTeam TEXT,
        awayTeam TEXT,
        tournament TEXT,
        logoTeamA TEXT,
        logoTeamB TEXT,
        home_score INTEGER,
        away_score INTEGER,
        minute INTEGER,
        dateTime TEXT,
        venue TEXT,
        oddsA REAL,      
        oddsB REAL       
      )
    ''';
    await db.execute(matchTable);


      // Tabla de Bets (apuestas)
    const betTable = '''
      CREATE TABLE bets (
        userId TEXT NOT NULL,
        eventId TEXT NOT NULL,
        stake REAL NOT NULL,
        odds REAL ,
        team TEXT NOT NULL,
        PRIMARY KEY (userId, eventId)
      );
    ''';
    await db.execute(betTable);


      // Tabla de Recommended Bets
  const recommendedBetTable = '''
    CREATE TABLE recommended_bets (
      recommendationId TEXT PRIMARY KEY,
      eventId TEXT,
      betType TEXT,
      description TEXT,
      createdAt TEXT
    )
  ''';
  await db.execute(recommendedBetTable);

  // Dentro de _createDB(Database db, int version) después de las otras tablas:
  const favoriteTable = '''
    CREATE TABLE favorites (
      userId TEXT NOT NULL,
      eventId TEXT NOT NULL,
      PRIMARY KEY (userId, eventId)
    )
  ''';
  await db.execute(favoriteTable);

  }

  // ****************** OPERACIONES CRUD ******************

    // ---------- Métodos para la tabla matches ----------
  // CREATE: Insertar un nuevo match
Future<int> insertMatch(MatchModel match) async {
  final db = await database;
  // Prepara el Map a insertar
  final matchMap = _prepareMatchForDb(match);
  return await db.insert(
    'matches',
    matchMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


Future<MatchModel?> getMatch(String eventId) async {
  final db = await database;
  final res = await db.query(
    'matches',
    where: 'eventId = ?',
    whereArgs: [eventId],
  );
  if (res.isNotEmpty) {
    // Convierte el registro plano a la estructura que espera fromJson()
    return MatchModel.fromJson(_convertDbRowToMatchJson(res.first));
  }
  return null;
}


Future<List<MatchModel>> getAllMatches() async {
  final db = await database;
  final res = await db.query('matches');
  // Para cada registro se realiza la conversión y luego se mapea a un objeto MatchModel
  return res.map((row) => MatchModel.fromJson(_convertDbRowToMatchJson(row))).toList();
}


 Future<int> updateMatch(MatchModel match) async {
  final db = await database;
  final matchMap = _prepareMatchForDb(match);
  return await db.update(
    'matches',
    matchMap,
    where: 'eventId = ?',
    whereArgs: [match.eventId],
  );
}


  // DELETE: Eliminar un match por su eventId
  Future<int> deleteMatch(String eventId) async {
    final db = await database;
    return await db.delete(
      'matches',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }


  /* ---------- NUEVO: filtra y recorta ---------- */
Future<void> _pruneNonFavoriteMatches() async {
  final db = await database;
  // 1. id‑s de favoritos
  final favIds = await db.query('favorites', columns: ['eventId']);
  final favSet = favIds.map((e) => e['eventId'] as String).toSet();

  // 2. seleccionar NO favoritos dentro de la ventana ±7 días
  final candidates = await db.rawQuery('''
    SELECT eventId, startTime
    FROM matches
    WHERE eventId NOT IN (${List.filled(favSet.length, '?').join(',')})
      AND startTime BETWEEN datetime('now','-7 days') 
                        AND datetime('now','+7 days')
    ORDER BY ABS(julianday(startTime) - julianday('now')) ASC
  ''', favSet.toList());

  // 3. si sobran más de 100, borra los excedentes
  const limit = 100;
  if (candidates.length > limit) {
    final toDelete = candidates.sublist(limit).map((m) => m['eventId']).toList();
    await db.delete(
      'matches',
      where: 'eventId IN (${List.filled(toDelete.length, '?').join(',')})',
      whereArgs: toDelete,
    );
  }
}

  /* ---------- modifica insert masivo ---------- */
  Future<void> insertMatchesBatch(List<MatchModel> matches) async {
    final db = await database;
    final batch = db.batch();

    final now = DateTime.now();
    final weekBefore = now.subtract(const Duration(days: 7));
    final weekAfter  = now.add(const Duration(days: 7));

    for (final m in matches) {
      // ignora si está fuera de ventana de una semana
      if (m.startTime.isBefore(weekBefore) || m.startTime.isAfter(weekAfter)) continue;
      batch.insert('matches', _prepareMatchForDb(m),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);

    await _pruneNonFavoriteMatches();   // <-- poda tras la inserción
  }



Map<String, dynamic> _prepareMatchForDb(MatchModel match) {
  final original = Map<String, dynamic>.from(match.toJson());
  original.remove('location');
  original.remove('isFavorite');
  // flatten location…
  original['locationLat'] = match.location.lat;
  original['locationLng'] = match.location.lng;
  // add odds
  original['oddsA'] = match.oddsA;
  original['oddsB'] = match.oddsB;
  return original;
}

Map<String, dynamic> _convertDbRowToMatchJson(Map<String, dynamic> row) {
  final mutableRow = Map<String, dynamic>.from(row);
  mutableRow['location'] = {
    'lat': mutableRow['locationLat'],
    'lng': mutableRow['locationLng'],
  };
  mutableRow['oddsA'] = row['oddsA'];
  mutableRow['oddsB'] = row['oddsB'];
  mutableRow['home_logo'] = mutableRow['logoTeamA'];
  mutableRow['away_logo'] = mutableRow['logoTeamB'];
  return mutableRow;
}


    // ---------- Métodos para la tabla Bets ----------

    Future<int> insertBet(BetModel bet) async {
    final db = await database;
    return await db.insert(
      'bets',
      bet.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BetModel?> getBet(String userId, String eventId) async {
    final db = await database;
    final res = await db.query(
      'bets',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
    if (res.isNotEmpty) {
      return BetModel.fromJson(res.first);
    }
    return null;
  }

  Future<List<BetModel>> getAllBets() async {
    final db = await database;
    final res = await db.query('bets');
    return res.map((json) => BetModel.fromJson(json)).toList();
  }

  Future<int> updateBet(BetModel bet) async {
    final db = await database;
    return await db.update(
      'bets',
      bet.toJson(),
      where: 'userId = ? AND eventId = ?',
      whereArgs: [bet.userId, bet.eventId],
    );
  }

  Future<int> deleteBet(String userId, String eventId) async {
    final db = await database;
    return await db.delete(
      'bets',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
  }

// ----------------- Métodos para RecommendedBet -----------------

// CREATE: Insertar una nueva RecommendedBet
Future<int> insertRecommendedBet(RecommendedBet bet) async {
  final db = await database;
  return await db.insert(
    'recommended_bets',
    bet.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// READ: Obtener una RecommendedBet por recommendationId
Future<RecommendedBet?> getRecommendedBet(String recommendationId) async {
  final db = await database;
  final res = await db.query(
    'recommended_bets',
    where: 'recommendationId = ?',
    whereArgs: [recommendationId],
  );
  if (res.isNotEmpty) {
    return RecommendedBet.fromJson(res.first);
  }
  return null;
}

// READ: Obtener todas las RecommendedBets
Future<List<RecommendedBet>> getAllRecommendedBets() async {
  final db = await database;
  final res = await db.query('recommended_bets');
  return res.map((row) => RecommendedBet.fromJson(row)).toList();
}

// UPDATE: Actualizar una RecommendedBet existente
Future<int> updateRecommendedBet(RecommendedBet bet) async {
  final db = await database;
  return await db.update(
    'recommended_bets',
    bet.toJson(),
    where: 'recommendationId = ?',
    whereArgs: [bet.recommendationId],
  );
}

// DELETE: Eliminar una RecommendedBet por recommendationId
Future<int> deleteRecommendedBet(String recommendationId) async {
  final db = await database;
  return await db.delete(
    'recommended_bets',
    where: 'recommendationId = ?',
    whereArgs: [recommendationId],
  );
}




}
