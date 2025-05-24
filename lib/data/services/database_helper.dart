// lib/data/services/database_helper.dart
//
// FULL, UNABRIDGED SOURCE  – version 3
//
// * v1  → initial schema
// * v2  → +oddsA / oddsB to matches
// * v3  → richer bets table (betId, teamId, match, sport, status, placedAt, updatedAt)
//         + batch insert + auto‑prune helpers
//
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/match_model.dart';
import '../models/bet_model.dart';
import '../models/recommended_bet_model.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  // ------------------------ singleton boilerplate ------------------------
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('matches.db');
    return _database!;
  }

  // ------------------------ init + migrations ------------------------
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // v2 – add odds to matches
          await db.execute('ALTER TABLE matches ADD COLUMN oddsA REAL DEFAULT 1.0;');
          await db.execute('ALTER TABLE matches ADD COLUMN oddsB REAL DEFAULT 1.0;');
        }
        if (oldV < 3) {
          // v3 – extend bets table
          await db.execute('ALTER TABLE bets ADD COLUMN betId   TEXT;');
          await db.execute('ALTER TABLE bets ADD COLUMN teamId  TEXT;');
          await db.execute('ALTER TABLE bets ADD COLUMN "match" TEXT;');
          await db.execute('ALTER TABLE bets ADD COLUMN sport   TEXT;');
          await db.execute('ALTER TABLE bets ADD COLUMN status  TEXT DEFAULT "placed";');
          await db.execute('ALTER TABLE bets ADD COLUMN placedAt  TEXT;');
          await db.execute('ALTER TABLE bets ADD COLUMN updatedAt TEXT;');
        }
        if (oldV < 4) {
           // v4 – support offline drafts
           await db.execute('ALTER TABLE bets ADD COLUMN isDraft INTEGER DEFAULT 0;');
           await db.execute('ALTER TABLE bets ADD COLUMN syncedAt TEXT;');
        }
        if (oldV < 5) {
          // v5 – add error_logs table
          await db.execute('''
            CREATE TABLE error_logs (
              id          INTEGER PRIMARY KEY AUTOINCREMENT,
              endpoint    TEXT    NOT NULL,
              error_type  TEXT    NOT NULL,
              timestamp   TEXT    NOT NULL
            );
          ''');
        }
        if (oldV < 6) {
          // v6 – add products table
          await db.execute('''
            CREATE TABLE products (
              id          TEXT PRIMARY KEY,
              name        TEXT,
              description TEXT,
              price       REAL,
              imageUrl    TEXT,
              category    TEXT
            );
          ''');
        }

        if (oldV < 7) {
          await db.execute('''
            CREATE TABLE product_views (
              id        INTEGER PRIMARY KEY AUTOINCREMENT,
              userId    TEXT NOT NULL,
              productId TEXT NOT NULL,
              viewedAt  TEXT NOT NULL,
              synced    INTEGER DEFAULT 0
            );
          ''');
        }

        if (oldV < 8) {
          await db.execute('''
            CREATE TABLE cart_items (
              id         TEXT PRIMARY KEY,
              userId     TEXT NOT NULL,
              productId  TEXT NOT NULL,
              quantity   INTEGER NOT NULL,
              addedAt    TEXT
            );
          ''');
        }
      },
    );
  }

  // ------------------------ schema creation ------------------------
  Future _createDB(Database db, int version) async {
    // MATCHES -----------------------------------------
    const matchesTable = '''
      CREATE TABLE matches (
        eventId      TEXT PRIMARY KEY,
        acidEventId  TEXT,
        name         TEXT,
        sport        TEXT,
        locationLat  REAL,
        locationLng  REAL,
        startTime    TEXT,
        status       TEXT,
        providerId   TEXT,
        homeTeam     TEXT,
        awayTeam     TEXT,
        tournament   TEXT,
        logoTeamA    TEXT,
        logoTeamB    TEXT,
        home_score   INTEGER,
        away_score   INTEGER,
        minute       INTEGER,
        dateTime     TEXT,
        venue        TEXT,
        oddsA        REAL,
        oddsB        REAL
      );
    ''';
    await db.execute(matchesTable);

    // BETS --------------------------------------------
    const betsTable = '''
      CREATE TABLE bets (
        betId     TEXT PRIMARY KEY,
        userId    TEXT NOT NULL,
        eventId   TEXT NOT NULL,
        teamId    TEXT,
        team      TEXT NOT NULL,
        stake     REAL NOT NULL,
        odds      REAL,
        "match"   TEXT,
        sport     TEXT,
        status    TEXT,
        placedAt  TEXT,
        updatedAt TEXT,
        isDraft   INTEGER DEFAULT 0,
        syncedAt  TEXT
      );
    ''';
    await db.execute(betsTable);

    // RECOMMENDED_BETS --------------------------------
    const recommendedBetTable = '''
      CREATE TABLE recommended_bets (
        recommendationId TEXT PRIMARY KEY,
        eventId   TEXT,
        betType   TEXT,
        description TEXT,
        createdAt TEXT
      );
    ''';
    await db.execute(recommendedBetTable);

    // FAVORITES ---------------------------------------
    const favoriteTable = '''
      CREATE TABLE favorites (
        userId  TEXT NOT NULL,
        eventId TEXT NOT NULL,
        PRIMARY KEY (userId, eventId)
      );
    ''';
    await db.execute(favoriteTable);

    // PRODUCTS ----------------------------------------
    const productsTable = '''
      CREATE TABLE products (
        id          TEXT PRIMARY KEY,
        name        TEXT,
        description TEXT,
        price       REAL,
        imageUrl    TEXT,
        category    TEXT
      );
    ''';
    await db.execute(productsTable);

    // define this at the top of your DatabaseHelper class
    const errorLogsTable = '''
      CREATE TABLE IF NOT EXISTS error_logs (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint    TEXT    NOT NULL,
        error_type  TEXT    NOT NULL,
        timestamp   TEXT    NOT NULL
      );
    ''';
    await db.execute(errorLogsTable);


        // ...............................................................
    // 2)  Initial schema  – add inside _createDB()
    // ...............................................................
    const productViewsTable = '''
      CREATE TABLE product_views (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        userId     TEXT NOT NULL,
        productId  TEXT    NOT NULL,
        viewedAt   TEXT    NOT NULL,
        synced     INTEGER DEFAULT 0
      );
    ''';
    await db.execute(productViewsTable);

    // CART_ITEMS ----------------------------------------
    const cartItemsTable = '''
      CREATE TABLE cart_items (
        id         TEXT PRIMARY KEY,
        userId     TEXT NOT NULL,
        productId  TEXT NOT NULL,
        quantity   INTEGER NOT NULL,
        addedAt    TEXT
      );
    ''';
    await db.execute(cartItemsTable);
    
  }
  

  // ************************************************************
  //   MATCHES  (single + batch + prune)
  // ************************************************************

  Future<int> insertMatch(MatchModel match) async {
    final db = await database;
    return await db.insert(
      'matches',
      _prepareMatchForDb(match),
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
      return MatchModel.fromJson(_convertDbRowToMatchJson(res.first));
    }
    return null;
  }

  Future<List<MatchModel>> getAllMatches() async {
    final db  = await database;
    final res = await db.query('matches');
    return res
        .map((row) => MatchModel.fromJson(_convertDbRowToMatchJson(row)))
        .toList();
  }

  Future<int> updateMatch(MatchModel match) async {
    final db = await database;
    return await db.update(
      'matches',
      _prepareMatchForDb(match),
      where: 'eventId = ?',
      whereArgs: [match.eventId],
    );
  }

  Future<int> deleteMatch(String eventId) async {
    final db = await database;
    return await db.delete(
      'matches',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  // ---------- BATCH INSERT + AUTO‑PRUNE para recommended_bets ----------
Future<void> insertRecommendedBetsBatch(List<RecommendedBet> recommendedBets) async {
  final db    = await database;
  final batch = db.batch();

  final now        = DateTime.now();
  final dayBefore  = now.subtract(const Duration(days: 1));  // Un día antes
  final dayAfter   = now.add(const Duration(days: 1));       // Un día después

  for (final bet in recommendedBets) {
    final createdAt = DateTime.parse(bet.createdAt.toString());
    if (createdAt.isBefore(dayBefore) || createdAt.isAfter(dayAfter)) {
      continue; // fuera de la ventana de ±1 día
    }
    batch.insert(
      'recommended_bets',
      bet.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  await batch.commit(noResult: true);

  // Limpiar las apuestas recomendadas que son más antiguas de 1 día
  await _pruneOldRecommendedBets();
}

// Eliminar las apuestas recomendadas viejas
Future<void> _pruneOldRecommendedBets() async {
  final db = await database;

  // Eliminar las apuestas recomendadas que tienen más de 1 día
  await db.delete(
    'recommended_bets',
    where: 'createdAt < ?',
    whereArgs: [DateTime.now().subtract(const Duration(days: 1)).toIso8601String()],
  );
}


  // ---------- BATCH INSERT + AUTO‑PRUNE ----------
  Future<void> insertMatchesBatch(List<MatchModel> matches) async {
    final db    = await database;
    final batch = db.batch();

    final now        = DateTime.now();
    final weekBefore = now.subtract(const Duration(days: 7));
    final weekAfter  = now.add(const Duration(days: 7));

    for (final m in matches) {
      if (m.startTime.isBefore(weekBefore) || m.startTime.isAfter(weekAfter)) {
        continue; // outside the ±7‑day window
      }
      batch.insert(
        'matches',
        _prepareMatchForDb(m),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    await _pruneNonFavoriteMatches();
  }

  Future<void> _pruneNonFavoriteMatches() async {
    final db = await database;

    // 1) set of favorite IDs
    final favRows = await db.query('favorites', columns: ['eventId']);
    final favSet  = favRows.map((r) => r['eventId'] as String).toSet();

    // 2) candidate non‑favorite matches inside ±7 days
    final cands = await db.rawQuery('''
      SELECT eventId
      FROM matches
      WHERE eventId NOT IN (${List.filled(favSet.length, '?').join(',')})
        AND startTime BETWEEN datetime('now','-7 days')
                          AND datetime('now','+7 days')
    ''', favSet.toList());

    // 3) keep only the 100 closest
    const limit = 100;
    if (cands.length > limit) {
      final toDelete =
          cands.sublist(limit).map((r) => r['eventId']).toList();
      await db.delete(
        'matches',
        where: 'eventId IN (${List.filled(toDelete.length, '?').join(',')})',
        whereArgs: toDelete,
      );
    }
  }

  // ---------- helpers ----------
  Map<String, dynamic> _prepareMatchForDb(MatchModel match) {
    final map = Map<String, dynamic>.from(match.toJson());

    // flatten location & odds
    map['locationLat'] = match.location.lat;
    map['locationLng'] = match.location.lng;
    map.remove('location');
    map.remove('isFavorite');

    return map;
  }

  Map<String, dynamic> _convertDbRowToMatchJson(Map<String, dynamic> row) {
    final m = Map<String, dynamic>.from(row);
    m['location'] = {'lat': m['locationLat'], 'lng': m['locationLng']};
    m['oddsA']    = m['oddsA'];
    m['oddsB']    = m['oddsB'];
    m['home_logo'] = m['logoTeamA'];
    m['away_logo'] = m['logoTeamB'];
    return m;
  }

  // ************************************************************
  //   BETS
  // ************************************************************

  Future<int> insertBet(BetModel bet) async {
    final db = await database;
    final map = bet.toJson();
    if (!map.containsKey('isDraft')) map['isDraft'] = 0;   // ← new line
    return await db.insert(
      'bets',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BetModel?> getBet(String userId, String eventId) async {
    final db  = await database;
    final res = await db.query(
      'bets',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
    if (res.isNotEmpty) return BetModel.fromJson(res.first);
    return null;
  }

  Future<List<BetModel>> getAllBets() async {
    final db  = await database;
    final res = await db.query('bets');
    return res.map((j) => BetModel.fromJson(j)).toList();
  }

  Future<List<BetModel>> getBetsForUser(String userId) async {
    final db  = await database;
    final res = await db.query(
      'bets',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return res.map((j) => BetModel.fromJson(j)).toList();
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

    /// Returns all locally‑saved draft rows (isDraft = 1)
  Future<List<Map<String, dynamic>>> getDraftRows() async {
    final db = await database;
    try {
      return await db.query(
        'bets',
        where: 'isDraft = ?',
        whereArgs: [1],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('no such column: isDraft')) {
        // patch any stray DBs on‑the‑fly
        await db.execute('ALTER TABLE bets ADD COLUMN isDraft INTEGER DEFAULT 0;');
        await db.execute('ALTER TABLE bets ADD COLUMN syncedAt TEXT;');
        return await db.query('bets', where: 'isDraft = ?', whereArgs: [1]);
      }
      rethrow;
    }
  }

  /// Marks a draft as synced (sets isDraft = 0 and stamps syncedAt)
  Future<void> markBetSynced(String userId, String eventId) async {
    final db = await database;
    await db.update(
      'bets',
      {
        'isDraft': 0,
        'syncedAt': DateTime.now().toIso8601String(),
      },
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
  }

  // ************************************************************
  //   RECOMMENDED BETS
  // ************************************************************

  Future<int> insertRecommendedBet(RecommendedBet bet) async {
    final db = await database;
    return await db.insert(
      'recommended_bets',
      bet.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<RecommendedBet?> getRecommendedBet(String id) async {
    final db  = await database;
    final res = await db.query(
      'recommended_bets',
      where: 'recommendationId = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) return RecommendedBet.fromJson(res.first);
    return null;
  }

  Future<List<RecommendedBet>> getAllRecommendedBets() async {
    final db  = await database;
    final res = await db.query('recommended_bets');
    return res.map((j) => RecommendedBet.fromJson(j)).toList();
  }

  Future<int> updateRecommendedBet(RecommendedBet bet) async {
    final db = await database;
    return await db.update(
      'recommended_bets',
      bet.toJson(),
      where: 'recommendationId = ?',
      whereArgs: [bet.recommendationId],
    );
  }

  Future<int> deleteRecommendedBet(String id) async {
    final db = await database;
    return await db.delete(
      'recommended_bets',
      where: 'recommendationId = ?',
      whereArgs: [id],
    );
  }

  // ************************************************************
  //   PRODUCTS
  // ************************************************************

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final res = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) return Product.fromJson(res.first);
    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final res = await db.query('products');
    return res.map((j) => Product.fromJson(j)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────── ERROR LOGS HELPERS ───────────────
  /// Insert a connection/error log into local storage.
  Future<void> insertErrorLog(String endpoint, String errorType) async {
    final db = await database;
    await db.insert(
      'error_logs',
      {
        'endpoint': endpoint,
        'error_type': errorType,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  /// Count all errors logged since [ago].
  Future<int> countErrorsSince(Duration ago) async {
    final db = await database;
    final since = DateTime.now().toUtc().subtract(ago).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM error_logs WHERE timestamp >= ?',
      [since],
    );
    // Sqflite.firstIntValue unwraps the single integer result
    return Sqflite.firstIntValue(result) ?? 0;
  }

  

// ────────────────────────────────────────────────────────────────
//   PRODUCT_VIEWS
// ────────────────────────────────────────────────────────────────

 Future<int> insertProductView(String productId, String userId) async {
  final db = await database;
  return await db.insert(
    'product_views',
    {
      'productId': productId,
      'viewedAt' : DateTime.now().toIso8601String(),
      'userId'   : userId,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

/// Total de vistas para un producto (todos los usuarios)
Future<int> countProductViews(String productId) async {
  final db = await database;
  final res = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM product_views WHERE productId = ?',
    [productId],
  );
  return Sqflite.firstIntValue(res) ?? 0;
}

/// Vistas de un producto hechas por un usuario específico
Future<int> countProductViewsByUser(String productId, String userId) async {
  final db = await database;
  final res = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM product_views '
    'WHERE productId = ? AND userId = ?',
    [productId, userId],
  );
  return Sqflite.firstIntValue(res) ?? 0;
}

/// Borra todas las vistas registradas para un producto (cualquier usuario)
Future<int> deleteProductViews(String productId) async {
  final db = await database;
  return await db.delete(
    'product_views',
    where: 'productId = ?',
    whereArgs: [productId],
  );
}

/// Borra por completo la tabla de vistas
Future<void> clearProductViews() async {
  final db = await database;
  await db.delete('product_views');
}

Future<List<Map<String, dynamic>>> getPendingProductViews({int limit = 500}) async {
  final db = await database;
    return await db.query(
    'product_views',
    columns: ['id', 'productId', 'userId', 'viewedAt'],   // <-- explícito
    where: 'synced = 0',
    orderBy: 'viewedAt DESC',
    limit: limit,
  );
}

Future<void> markProductViewsSynced(List<int> ids) async {
  if (ids.isEmpty) return;
  final db = await database;
  final placeholders = List.filled(ids.length, '?').join(',');
  await db.rawUpdate(
    'UPDATE product_views SET synced = 1 WHERE id IN ($placeholders)',
    ids.map((e) => e as Object).toList(),   // ← sqflite espera List<Object?>
  );
}

// ────────────────────────────────────────────────────────────────
//   PRODUCT_VIEWS
// ────────────────────────────────────────────────────────────────
  Future<int> addCartItem({
    required String id,
    required String userId,
    required String productId,
    required int quantity,
    DateTime? addedAt,
  }) async {
    final db = await database;
    print('Adding cart item to local storage: $id');
    return await db.insert(
      'cart_items',
      {
        'id': id,
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
        'addedAt': (addedAt ?? DateTime.now()).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
  final db = await database;
  print('Fetching cart items for user in local storage: $userId');
  return await db.query(
    'cart_items',
    where: 'userId = ?',
    whereArgs: [userId],
  );
}

Future<int> removeCartItem(String id) async {
  final db = await database;
  print('Removing cart item with ID from local storage: $id');
  return await db.delete(
    'cart_items',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> clearCartItems(String userId) async {
  final db = await database;
  print('Clearing all cart items for user in local storage: $userId');
  return await db.delete(
    'cart_items',
    where: 'userId = ?',
    whereArgs: [userId],
  );
}
}
