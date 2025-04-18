// lib/data/models/bet_model.dart

/// A single bet as returned by `/api/bets/*` routes.
///
/// The backend was recently extended – fields like `betId`, `teamId`, `match`,
/// `sport`, `status`, and camel‑cased `placedAt`/`updatedAt` were added.
/// This model **accepts both the old snake_case** keys (created_at/updated_at)
/// **and the new camelCase** ones to stay backward‑compatible with any
/// persisted JSON or older API versions.
class BetModel {
  // ---------- identifiers (may be absent on very old data) ----------
  final String? betId;     // new – primary key returned by backend
  final String userId;     // Firebase UID (always present)
  final String eventId;    // backend event/acid_event / foreign key
  final String? teamId;    // new – ID of the chosen team

  // ---------- presentation ----------
  final String team;       // the *name* of the chosen team (legacy key "team")
  final String? matchName; // e.g. "Team A vs Team B" – new key "match"
  final String? sport;     // basketball, football, …

  // ---------- numbers ----------
  final double stake;      // amount wagered
  final double? odds;      // decimal odds at the time of placement

  // ---------- status / timestamps ----------
  final String status;     // placed / won / lost (defaults to placed)
  final DateTime? createdAt; // legacy (mapped from placedAt if present)
  final DateTime? updatedAt;

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
  });

  // ------------------------------------------------------------------
  // JSON ⇆ object helpers.
  // ------------------------------------------------------------------

  factory BetModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse a timestamp or return null
    DateTime? _parseDate(dynamic v) {
      if (v == null || v.toString().isEmpty) return null;
      return DateTime.tryParse(v as String);
    }

    return BetModel(
      betId:   json['betId']      ?? json['id'],            // id fallback
      userId:  json['userId']     ?? json['user'] ?? '',
      eventId: json['eventId']    ?? json['event'] ?? '',
      teamId:  json['teamId'],                               // optional
      team:    json['team']        ?? json['yourTeam'] ?? '',
      stake:   (json['stake'] as num).toDouble(),
      odds:    json['odds'] != null ? (json['odds'] as num).toDouble() : null,
      matchName: json['match'],
      sport:     json['sport'],
      status:    json['status'] ?? 'placed',
      createdAt: _parseDate(json['placedAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (betId != null) 'betId': betId,
      'userId':  userId,
      'eventId': eventId,
      if (teamId != null) 'teamId': teamId,
      'team':    team,
      'stake':   stake,
      if (odds != null) 'odds': odds,
      if (matchName != null) 'match': matchName,
      if (sport != null)     'sport': sport,
      'status':  status,
      if (createdAt != null) 'placedAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
