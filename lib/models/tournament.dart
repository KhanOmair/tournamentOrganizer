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
  final List<Group> groups;
  final String sport;
  final List<TopScorer> topScorers;

  Tournament({
    required this.participants,
    required this.id,
    required this.teams,
    required this.groups,
    required this.name,
    required this.type,
    required this.status,
    required this.startDate,
    required this.playerIds,
    required this.rounds,
    required this.sport,
    required this.topScorers,
  });

  factory Tournament.fromFirestore(Map<String, dynamic> data, String docId) {
    return Tournament(
      groups: List<Group>.from(
        (data['groups'] as List<dynamic>?)?.map(
              (groupData) => Group.fromMap(groupData),
            ) ??
            [],
      ),
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
      sport: data['sport'] ?? '',
      topScorers: List<TopScorer>.from(
        (data['topScorers'] as List<dynamic>?)?.map(
              (teamData) => TopScorer.fromMap(teamData),
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
      'groups': groups.map((group) => group.toMap()).toList(),
      'sport': sport,
      'topscorers': topScorers.map((topscorer) => topscorer.toMap()).toList(),
    };
  }
}

class Group {
  final String id;
  final String name;
  final List<Team> teams;

  Group({required this.id, required this.name, required this.teams});

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      teams: List<Team>.from(
        (data['teams'] as List<dynamic>?)?.map(
              (teamData) => Team.fromMap(teamData),
            ) ??
            [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teams': teams.map((team) => team.toMap()).toList(),
    };
  }
}

class TopScorer {
  final String id;
  final String name;
  final int goals;

  TopScorer({required this.id, required this.name, required this.goals});

  factory TopScorer.fromMap(Map<String, dynamic> data) {
    return TopScorer(
      id: data['playerId'] ?? '',
      name: data['name'] ?? '',
      goals: data['goals'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'playerId': id, 'name': name, 'goals': goals};
  }
}
