import 'package:tourney_app/models/team.dart';

class GameMatch {
  final String id;
  final String type; // singles | doubles
  final String status; // completed | upcoming
  final List<String> playerIds; // Global player IDs
  final MatchScore scores;
  final String winner; // team1 | team2
  final Team team1;
  final Team team2;

  GameMatch({
    required this.id,
    required this.type,
    required this.status,
    required this.playerIds,
    required this.scores,
    required this.winner,
    required this.team1,
    required this.team2,
  });

  factory GameMatch.fromFirestore(Map<String, dynamic> data, String docId) {
    return GameMatch(
      id: docId,
      team1: Team.fromMap(data['team1'] ?? {}),
      team2: Team.fromMap(data['team2'] ?? {}),
      type: data['type'] ?? 'singles',
      status: data['status'] ?? 'upcoming',
      playerIds: List<String>.from(data['playerIds'] ?? []),
      scores: MatchScore.fromMap(data['scores'] ?? {}),
      winner: data['winner'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'team1': team1.toMap(),
      'team2': team2.toMap(),
      'type': type,
      'status': status,
      'playerIds': playerIds,
      'scores': scores.toMap(),
      'winner': winner,
    };
  }
}

class MatchScore {
  final int team1;
  final int team2;

  MatchScore({required this.team1, required this.team2});

  factory MatchScore.fromMap(Map<String, dynamic> map) {
    return MatchScore(team1: map['team1'] ?? 0, team2: map['team2'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'team1': team1, 'team2': team2};
  }
}
