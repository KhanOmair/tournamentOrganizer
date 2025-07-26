import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourney_app/models/match.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';

Team _updateTeamStats(Team team, int goalsFor, int goalsAgainst) {
  int wins = team.wins;
  int losses = team.losses;
  int draws = team.draws;

  if (goalsFor > goalsAgainst) {
    wins++;
  } else if (goalsFor < goalsAgainst) {
    losses++;
  } else {
    draws++;
  }

  return Team(
    teamId: team.teamId,
    teamName: team.teamName,
    playerIdsTeam: team.playerIdsTeam,
    played: team.played + 1,
    wins: wins,
    draws: draws,
    losses: losses,
    goalsFor: team.goalsFor + goalsFor,
    goalsAgainst: team.goalsAgainst + goalsAgainst,
  );
}

Future<void> _updatePlayerStats(GameMatch match, String winner) async {
  for (String playerId in match.team1.playerIdsTeam) {
    final playerRef = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId);
    await playerRef.update({
      'globalStats.matchesPlayed': FieldValue.increment(1),
      'globalStats.wins': winner == 'team1'
          ? FieldValue.increment(1)
          : FieldValue.increment(0),
      'globalStats.losses': winner == 'team2'
          ? FieldValue.increment(1)
          : FieldValue.increment(0),
    });
  }

  for (String playerId in match.team2.playerIdsTeam) {
    final playerRef = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId);
    await playerRef.update({
      'globalStats.matchesPlayed': FieldValue.increment(1),
      'globalStats.wins': winner == 'team2'
          ? FieldValue.increment(1)
          : FieldValue.increment(0),
      'globalStats.losses': winner == 'team1'
          ? FieldValue.increment(1)
          : FieldValue.increment(0),
    });
  }
}

Future<void> updateMatchScore({
  required String tournamentId,
  required String roundId,
  required String matchId,
  required int team1Score,
  required int team2Score,
}) async {
  final tournamentRef = FirebaseFirestore.instance
      .collection('tournaments')
      .doc(tournamentId);

  try {
    final tournamentSnapshot = await tournamentRef.get();

    if (!tournamentSnapshot.exists) {
      throw Exception('Tournament not found');
    }

    final data = tournamentSnapshot.data()!;
    List<dynamic> rounds = data['rounds'] ?? [];
    List<dynamic> teamsList = data['teams'] ?? [];

    // Find the specific round
    final roundIndex = rounds.indexWhere((r) => r['id'] == roundId);
    if (roundIndex == -1) throw Exception('Round not found');

    // Find the specific match
    List<dynamic> matches = rounds[roundIndex]['matches'];
    final matchIndex = matches.indexWhere((m) => m['id'] == matchId);
    if (matchIndex == -1) throw Exception('Match not found');

    Map<String, dynamic> matchMap = matches[matchIndex];

    // Convert to GameMatch model
    GameMatch match = GameMatch.fromFirestore(matchMap, matchId);

    // Determine winner
    String winner = '';
    if (team1Score > team2Score) {
      winner = 'team1';
    } else if (team2Score > team1Score) {
      winner = 'team2';
    } else {
      winner = 'draw';
    }

    // Update match details
    Team updatedTeam1 = _updateTeamStats(match.team1, team1Score, team2Score);
    Team updatedTeam2 = _updateTeamStats(match.team2, team2Score, team1Score);

    match = GameMatch(
      id: match.id,
      type: match.type,
      status: 'completed',
      playerIds: match.playerIds,
      scores: MatchScore(team1: team1Score, team2: team2Score),
      winner: winner,
      team1: updatedTeam1,
      team2: updatedTeam2,
    );

    // Update players' global stats
    await _updatePlayerStats(match, winner);

    // Update teams list in the tournament
    for (int i = 0; i < teamsList.length; i++) {
      Map<String, dynamic> teamMap = teamsList[i];
      if (teamMap['teamId'] == match.team1.teamId) {
        teamMap['played'] = (teamMap['played'] ?? 0) + 1;
        teamMap['goalsFor'] = (teamMap['goalsFor'] ?? 0) + team1Score;
        teamMap['goalsAgainst'] = (teamMap['goalsAgainst'] ?? 0) + team2Score;
        if (team1Score > team2Score) {
          teamMap['wins'] = (teamMap['wins'] ?? 0) + 1;
        } else if (team1Score < team2Score) {
          teamMap['losses'] = (teamMap['losses'] ?? 0) + 1;
        } else {
          teamMap['draws'] = (teamMap['draws'] ?? 0) + 1;
        }
        teamsList[i] = teamMap;
      }
      if (teamMap['teamId'] == match.team2.teamId) {
        teamMap['played'] = (teamMap['played'] ?? 0) + 1;
        teamMap['goalsFor'] = (teamMap['goalsFor'] ?? 0) + team2Score;
        teamMap['goalsAgainst'] = (teamMap['goalsAgainst'] ?? 0) + team1Score;
        if (team2Score > team1Score) {
          teamMap['wins'] = (teamMap['wins'] ?? 0) + 1;
        } else if (team2Score < team1Score) {
          teamMap['losses'] = (teamMap['losses'] ?? 0) + 1;
        } else {
          teamMap['draws'] = (teamMap['draws'] ?? 0) + 1;
        }
        teamsList[i] = teamMap;
      }
    }

    // Replace updated match in matches list
    matches[matchIndex] = match.toFirestore();

    // Replace updated round in rounds list
    rounds[roundIndex]['matchIds'] = matches;

    // Save updated tournament
    await tournamentRef.update({'rounds': rounds, 'teams': teamsList});

    // add logic to update the status of the tournament if the final match is completed
    if (match.type == 'final' && winner.isNotEmpty) {
      await tournamentRef.update({'status': 'completed'});
    }

    print('Match score and team stats updated successfully ✅');
  } catch (e) {
    print('Error updating match score: $e');
    rethrow;
  }
}

Future<void> createFinalMatch(String tournamentId) async {
  List<Team> sortTeams(List<Team> unsortedTeams) {
    final sorted = List<Team>.from(unsortedTeams);
    sorted.sort((a, b) {
      // Sort by Points
      if (b.points != a.points) return b.points.compareTo(a.points);

      // If Points equal, sort by Goal Difference
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // If GD equal, sort by Wins
      if (b.wins != a.wins) return b.wins.compareTo(a.wins);

      // If all equal, sort alphabetically
      return a.teamName.compareTo(b.teamName);
    });
    return sorted;
  }

  final tournamentRef = FirebaseFirestore.instance
      .collection('tournaments')
      .doc(tournamentId);

  final snapshot = await tournamentRef.get();
  final data = snapshot.data()!;
  Tournament t = Tournament.fromFirestore(data, tournamentId);

  // Get sorted teams
  List<Team> teamsList = List<Team>.from(t.teams);

  if (teamsList.length < 2) {
    throw Exception('Not enough teams to create a final');
  }

  List<Team> sortedTeams = sortTeams(teamsList);

  Team topTeam1 = sortedTeams[0];
  Team topTeam2 = sortedTeams[1];

  List<String> tplayerIds = [];
  if (topTeam1.playerIdsTeam.isNotEmpty) {
    tplayerIds.addAll(topTeam1.playerIdsTeam);
  }
  if (topTeam2.playerIdsTeam.isNotEmpty) {
    tplayerIds.addAll(topTeam2.playerIdsTeam);
  }

  // Create a new final match
  String matchId = 'final_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> finalMatch = {
    'id': matchId,
    'type': 'final',
    'status': 'upcoming',
    'playerIds': tplayerIds,
    'team1': topTeam1.toMap(),
    'team2': topTeam2.toMap(),
    'scores': {topTeam1.teamName: 0, topTeam2.teamName: 0},
    'winner': '',
  };

  // Add to a new round called "Final"
  Map<String, dynamic> finalRound = {
    'id': 'round_final',
    'name': 'Final',
    'roundNumber': (data['rounds'] as List).length + 1,
    'matches': [finalMatch],
  };

  // Update Firestore
  List<dynamic> updatedRounds = List.from(data['rounds'] ?? []);
  updatedRounds.add(finalRound);

  await tournamentRef.update({'rounds': updatedRounds});
}
