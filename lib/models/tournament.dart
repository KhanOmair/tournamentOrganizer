import 'package:tourney_app/models/round.dart';
import 'package:tourney_app/models/team.dart';

/* 
tournaments (collection)
  tournamentId (doc)
    ├── name: "Spring Cup"
    ├── type: "Single Elimination"
    ├── status: "active"
    ├── date: "2025-07-10"
    ├── playerIds: [playerId1, playerId2, ...]
    ├── rounds (subcollection) (can be added dynamically)
    │     roundId (doc)
    │        ├── name: "Quarter Finals"
    │        ├── roundNumber: 2
    │        ├── matches (subcollection)
    │              matchId (doc)
    │                 ├── type: "singles" | "doubles"
    │                 ├── status: "completed" | "upcoming"
    │                 ├── playerIds: [playerId1, playerId2]
    │                 ├── scores: { team1: 11, team2: 7 }
    │                 ├── winner: team1

*/

class Tournament {
  final String id;
  final String name;
  final String type; // e.g., "Round Robin"
  final String status; // active, completed
  final DateTime startDate; // Tournament start date
  final List<String> playerIds;
  final List<Round> rounds; // List of round IDs
  final List<Team> teams;
  final List<String> participants;

  Tournament({
    required this.participants,
    required this.id,
    required this.teams,
    required this.name,
    required this.type,
    required this.status,
    required this.startDate,
    required this.playerIds,
    required this.rounds,
  });

  factory Tournament.fromFirestore(Map<String, dynamic> data, String docId) {
    return Tournament(
      participants: List<String>.from(data['participants'] ?? []),
      teams: List<Team>.from(
        (data['teams'] as List<dynamic>?)?.map(
              (teamData) => Team.fromMap(teamData),
            ) ??
            [],
      ),
      id: docId,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      status: data['status'] ?? 'upcoming',
      startDate: data['startDate'].toDate() ?? "",
      playerIds: List<String>.from(data['playerIds'] ?? []),
      rounds: List<Round>.from(
        (data['rounds'] as List<dynamic>?)?.map(
              (roundData) => Round.fromFirestore(roundData, roundData['id']),
            ) ??
            [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'status': status,
      'startDate': startDate,
      'playerIds': playerIds,
      'rounds': rounds,
      'teams': teams.map((team) => team.toMap()).toList(),
      'participants': participants,
    };
  }
}
