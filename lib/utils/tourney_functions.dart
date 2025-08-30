import 'package:tourney_app/models/tournament.dart';

List<Map<String, dynamic>> generateGroupVsGroupRounds(List<Group> groups) {
  // 1️⃣ Generate all group-vs-group matches
  final List<Map<String, dynamic>> allMatches = [];

  for (int g1 = 0; g1 < groups.length; g1++) {
    final group1 = groups[g1];
    final teams1 = group1.teams;

    for (int g2 = g1 + 1; g2 < groups.length; g2++) {
      final group2 = groups[g2];
      final teams2 = group2.teams;

      int m = teams1.length; // equal players in each group

      // Pair each player in group1 with one player in group2
      for (int i = 0; i < m; i++) {
        final team1 = teams1[i];
        final team2 = teams2[i % m];

        allMatches.add({
          'id': '${group1.name}_${team1.teamId}_vs_${group2.name}_${team2.teamId}',
          'type': 'singles',
          'status': 'upcoming',
          'playerIds': [...team1.playerIdsTeam, ...team2.playerIdsTeam],
          'team1': team1.toMap(),
          'team2': team2.toMap(),
          'scores': {team1.teamName: 0, team2.teamName: 0},
          'winner': '',
          'streamUrl': '',
          'groups': '${group1.name} vs ${group2.name}',
        });
      }
    }
  }

  // 2️⃣ Distribute matches into rounds
  final int totalPlayers = groups.fold(0, (sum, g) => sum + g.teams.length);
  final int maxMatchesPerRound = totalPlayers ~/ 2; // each player plays at most once
  final List<Map<String, dynamic>> rounds = [];

  int roundNumber = 1;
  final List<Map<String, dynamic>> pool = List.from(allMatches);

  while (pool.isNotEmpty) {
    final List<Map<String, dynamic>> currentRound = [];
    final Set<String> scheduledPlayers = {};

    pool.removeWhere((match) {
      final players = List<String>.from(match['playerIds']);

      // Skip match if any player is already scheduled this round
      if (players.any(scheduledPlayers.contains)) return false;

      // Enforce max matches per round
      if (currentRound.length >= maxMatchesPerRound) return false;

      // Assign match to this round
      currentRound.add(match);
      scheduledPlayers.addAll(players);
      return true; // remove from pool
    });

    rounds.add({
      'id': 'round_$roundNumber',
      'name': 'Round $roundNumber',
      'roundNumber': roundNumber,
      'matches': currentRound,
    });

    roundNumber++;
  }

  return rounds;
}
