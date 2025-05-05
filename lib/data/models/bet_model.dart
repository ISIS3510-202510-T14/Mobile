// lib/data/models/bet_model.dart
// UPDATED – adds offline‑draft fields (isDraft, syncedAt) and keeps backward‑compat

/// A single bet as returned by `/api/bets/*` routes **or** stored locally.
///
/// The model supports both the newest backend fields (camelCase) and legacy
/// snake_case keys, plus two extra columns used only by the local SQLite cache:
///   * `isDraft`  → 1 if the bet was saved while offline and still pending sync
///   * `syncedAt` → ISO timestamp when the draft was successfully synced
class BetModel {
  // ---------- identifiers ----------
  final String? betId;     // primary key from backend (may be null on drafts)
  final String userId;     // Firebase UID
  final String eventId;    // backend eventId / foreign key
  final String? teamId;    // optional – chosen team id

  // ---------- presentation ----------
  final String team;       // name of the chosen team
  final String? matchName; // e.g. "Team A vs Team B"
  final String? sport;     // basketball, football, …

  // ---------- numbers ----------
  final double stake;      // amount wagered
  final double? odds;      // decimal odds at placement time

  // ---------- status / timestamps ----------
  final String status;     // placed / won / lost
  final DateTime? createdAt;  // placedAt (legacy created_at)
  final DateTime? updatedAt;

  // ---------- offline‑sync helpers ----------
  final int isDraft;            // 0 = normal, 1 = awaiting sync
  final DateTime? syncedAt;     // set when local draft successfully POSTed

  const BetModel({
    this.betId,
    required this.userId,
    required this.eventId,
    this.teamId,
    required this.team,
    required this.stake,
    this.odds,
    this.matchName,
    this.sport,
    this.status = 'placed',
    this.createdAt,
    this.updatedAt,
    this.isDraft = 0,
    this.syncedAt,
  });

  // ------------------------------------------------------------------
  // JSON ⇆ object helpers.
  // ------------------------------------------------------------------

  factory BetModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null || v.toString().isEmpty) return null;
      return DateTime.tryParse(v as String);
    }

    int _parseDraft(dynamic v) {
      if (v == 1 || v == true) return 1;
      return 0;
    }

    return BetModel(
      betId   : json['betId']      ?? json['id'],
      userId  : json['userId']     ?? json['user'] ?? '',
      eventId : json['eventId']    ?? json['event'] ?? '',
      teamId  : json['teamId'],
      team    : json['team']       ?? json['yourTeam'] ?? '',
      stake   : (json['stake'] as num).toDouble(),
      odds    : json['odds'] != null ? (json['odds'] as num).toDouble() : null,
      matchName : json['match'],
      sport     : json['sport'],
      status    : json['status'] ?? 'placed',
      createdAt : _parseDate(json['placedAt'] ?? json['created_at']),
      updatedAt : _parseDate(json['updatedAt'] ?? json['updated_at']),
      isDraft   : _parseDraft(json['isDraft']),
      syncedAt  : _parseDate(json['syncedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (betId != null) 'betId': betId,
      'userId' : userId,
      'eventId': eventId,
      if (teamId != null) 'teamId': teamId,
      'team'   : team,
      'stake'  : stake,
      if (odds != null) 'odds': odds,
      if (matchName != null) 'match': matchName,
      if (sport != null)     'sport': sport,
      'status'   : status,
      if (createdAt != null) 'placedAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isDraft'  : isDraft,
      if (syncedAt != null) 'syncedAt': syncedAt!.toIso8601String(),
    };
  }
}
