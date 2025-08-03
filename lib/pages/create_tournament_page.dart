import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/custom_teams_page.dart';
import 'package:tourney_app/utils/tournament_crud.dart';
import 'package:tourney_app/widgets/grouping_widget.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedType;
  List<String> _selectedPlayerIds = [];

  List<Team> teams = [];
  List<Group> groups = [];

  bool _isLoading = false;
  bool isDoubles = true;
  bool teamsCreated = false;
  bool isCustomTeams = false;
  bool choosingFinalist = false;
  bool makeGroups = false;
  bool arePlayersSelected = false;

  Team finalistTeam = Team(
    teamId: "not_selected",
    teamName: "BYE",
    playerIdsTeam: ["BYE"],
    played: 0,
    wins: 0,
    draws: 0,
    losses: 0,
    goalsFor: 0,
    goalsAgainst: 0,
  );

  Future<List<Team>> _generateTeams() async {
    if (isDoubles == true) {
      List<Team> teams = [];
      if (_selectedPlayerIds.length % 2 != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The number of players must be even to generate teams.',
            ),
          ),
        );
        return [];
      }

      // Shuffle players randomly
      List<String> shuffledPlayers = List.from(_selectedPlayerIds);
      shuffledPlayers.shuffle(Random());

      // Pair players into teams of 2
      for (int i = 0; i < shuffledPlayers.length; i += 2) {
        final player1 = shuffledPlayers[i];
        final player2 = shuffledPlayers[i + 1];

        String pl1Name = await getPlayerName(player1);
        String pl2Name = await getPlayerName(player2);

        Team team = Team(
          teamId: DateTime.now().millisecondsSinceEpoch.toString(),
          teamName: "$pl1Name & $pl2Name",
          playerIdsTeam: [player1, player2],
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goalsFor: 0,
          goalsAgainst: 0,
        );
        teams.add(team);
      }

      return teams;
    }
    // If not doubles, generate teams of singles
    else {
      List<Team> teams = [];
      if (_selectedPlayerIds.length % 2 != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The number of players must be even to generate teams.',
            ),
          ),
        );
        return [];
      }

      // Shuffle players randomly
      List<String> shuffledPlayers = List.from(_selectedPlayerIds);
      shuffledPlayers.shuffle(Random());

      for (var player in shuffledPlayers) {
        String playerName = await getPlayerName(player);
        Team team = Team(
          teamId: DateTime.now().millisecondsSinceEpoch.toString(),
          teamName: playerName,
          playerIdsTeam: [player],
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goalsFor: 0,
          goalsAgainst: 0,
        );
        teams.add(team);
      }

      return teams;
    }
  }

  void _showTeamDialog(BuildContext context) {
    if (_selectedPlayerIds.length % 2 != 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Invalid Player Count'),
          content: const Text(
            'Please select an even number of players to form teams.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _generateAndShowTeams(context);
  }

  void _generateAndShowTeams(BuildContext context) async {
    List<Team> tteams = await _generateTeams();

    showModalBottomSheet(
      context: context,
      // make sure to make this in the future builder
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 700,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  'Random Teams',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (tteams.length.isOdd)
                  Text(
                    'Choose a team to be the finalist(optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: tteams.length,
                    itemBuilder: (context, index) {
                      final team = tteams[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Row(
                          children: [
                            Text(team.teamName),
                            Spacer(),

                            if (tteams.length.isOdd)
                              Checkbox(
                                value: team.teamId == finalistTeam.teamId,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      finalistTeam = team;
                                      finalistTeam = Team(
                                        teamId: team.teamId,
                                        teamName: team.teamName,
                                        playerIdsTeam: team.playerIdsTeam,
                                        played: team.played,
                                        wins: 20,
                                        draws: team.draws,
                                        losses: team.losses,
                                        goalsFor: team.goalsFor,
                                        goalsAgainst: team.goalsAgainst,
                                      );
                                    } else {
                                      finalistTeam = Team(
                                        teamId: "bye_1",
                                        teamName: "BYE",
                                        playerIdsTeam: ["BYE"],
                                        played: 0,
                                        wins: 0,
                                        draws: 0,
                                        losses: 0,
                                        goalsFor: 0,
                                        goalsAgainst: 0,
                                      );
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Regenerate Teams
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  child: const Text('Regenerate'),
                ),
                TextButton(
                  onPressed: () {
                    teams = tteams; // Save the generated teams
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate() ||
        _selectedType == null ||
        teamsCreated == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and select players'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // find the finalist team from the teams list
      if (finalistTeam.teamId != "not_selected" && groups.isNotEmpty) {
        var totalTeamsInG;
        for (var group in groups) {
          if (group.teams.any((team) => team.teamId == finalistTeam.teamId)) {
            final totalTeamsInGroup = group.teams.length;
            totalTeamsInG = totalTeamsInGroup;

            final simulatedMatches = totalTeamsInGroup - 1;
            final avgGoalsForPerMatch = 1;
            final avgGoalsAgainstPerMatch = 0;

            final simulatedPlayed = simulatedMatches;
            final simulatedWins = simulatedMatches;
            final simulatedDraws = 0;
            final simulatedLosses = 0;
            final simulatedGoalsFor = simulatedMatches * avgGoalsForPerMatch;
            final simulatedGoalsAgainst =
                simulatedMatches * avgGoalsAgainstPerMatch;
            group.teams.removeWhere(
              (team) => team.teamId == finalistTeam.teamId,
            );
            group.teams.add(
              Team(
                teamId: finalistTeam.teamId,
                teamName: finalistTeam.teamName,
                playerIdsTeam: finalistTeam.playerIdsTeam,
                played: simulatedPlayed,
                wins: simulatedWins,
                draws: simulatedDraws,
                losses: simulatedLosses,
                goalsFor: simulatedGoalsFor,
                goalsAgainst: simulatedGoalsAgainst,
              ),
            );
          }
        }

        final ssimulatedMatches = totalTeamsInG - 1;
        final avgGoalsForPerMatch = 1;
        final avgGoalsAgainstPerMatch = 0;
        final ssimulatedPlayed = ssimulatedMatches;
        final ssimulatedWins = ssimulatedMatches;
        final ssimulatedDraws = 0;
        final ssimulatedLosses = 0;
        final ssimulatedGoalsFor = ssimulatedMatches * avgGoalsForPerMatch;
        final ssimulatedGoalsAgainst =
            ssimulatedMatches * avgGoalsAgainstPerMatch;

        teams.removeWhere((team) => team.teamId == finalistTeam.teamId);
        teams.add(
          Team(
            teamId: finalistTeam.teamId,
            teamName: finalistTeam.teamName,
            playerIdsTeam: finalistTeam.playerIdsTeam,
            played: ssimulatedPlayed,
            wins: ssimulatedWins,
            draws: ssimulatedDraws,
            losses: ssimulatedLosses,
            goalsFor: ssimulatedGoalsFor,
            goalsAgainst: ssimulatedGoalsAgainst,
          ),
        );
      } else if (finalistTeam.teamId != "not_selected") {
        final totalTeamsInGroup = teams.length;

        final simulatedMatches = totalTeamsInGroup - 1;
        final avgGoalsForPerMatch = 1;
        final avgGoalsAgainstPerMatch = 0;

        final simulatedPlayed = simulatedMatches;
        final simulatedWins = simulatedMatches;
        final simulatedDraws = 0;
        final simulatedLosses = 0;
        final simulatedGoalsFor = simulatedMatches * avgGoalsForPerMatch;
        final simulatedGoalsAgainst =
            simulatedMatches * avgGoalsAgainstPerMatch;
        teams.removeWhere((team) => team.teamId == finalistTeam.teamId);
        teams.add(
          Team(
            teamId: finalistTeam.teamId,
            teamName: finalistTeam.teamName,
            playerIdsTeam: finalistTeam.playerIdsTeam,
            played: simulatedPlayed,
            wins: simulatedWins,
            draws: simulatedDraws,
            losses: simulatedLosses,
            goalsFor: simulatedGoalsFor,
            goalsAgainst: simulatedGoalsAgainst,
          ),
        );
      }
      // Generate rounds + matches
      final rounds = await _generateRoundsAndMatches(
        teams: teams,
        type: _selectedType!,
      );

      // Save tournament (with rounds)
      await FirebaseFirestore.instance
          .collection('tournaments')
          .add({
            'name': _nameController.text.trim(),
            'type': _selectedType,
            'status': 'upcoming',
            'startDate': DateTime.parse(_dateController.text.trim()),
            'playerIds': _selectedPlayerIds,
            'rounds': rounds,
            'createdAt': FieldValue.serverTimestamp(),
            'teams': teams.map((team) => team.toMap()).toList(),
            'groups': groups.map((group) => group.toMap()).toList(),
          })
          .then((onValue) async {
            // Update tournamentsPlayed for each player

            // create a list of playerIds from teams
            List<String> playerIds = [];
            for (var team in teams) {
              playerIds.addAll(team.playerIdsTeam);
            }
            await updateTournamentsPlayedForPlayers(playerIds);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament created successfully')),
            );

            Navigator.pop(context); // Close the create tournament page
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating tournament: $error')),
            );
          });

      // Go back
    } catch (e) {
      print(e);
      print(teams.map((team) => team.toMap()).toList());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _generateRoundsAndMatches({
    required List<Team> teams,
    required String type,
  }) async {
    List<Map<String, dynamic>> rounds = [];

    if (type == 'Round Robin') {
      rounds = _generateRoundRobin(teams);
    } else if (type == 'Group Format') {
      rounds = _generateGroupFormat(groups);
    } else if (type == 'Double Elimination') {
      // rounds = _generateDoubleElimination(players);
    }

    return rounds;
  }

  List<Map<String, dynamic>> _generateGroupFormat(List<Group> groups) {
    if (finalistTeam.teamId != "not_selected") {
      List<Map<String, dynamic>> r = [];
      for (var group in groups) {
        List<Team> teamList = List.from(group.teams);

        teamList.removeWhere((team) => team.teamId == finalistTeam.teamId);

        if (teamList.length.isOdd) {
          teamList.add(
            Team(
              teamId: DateTime.now().millisecondsSinceEpoch.toString(),
              teamName: "BYE",
              playerIdsTeam: ["BYE"],
              played: 0,
              wins: 0,
              draws: 0,
              losses: 0,
              goalsFor: 0,
              goalsAgainst: 0,
            ),
          );
        }

        int numTeams = teamList.length;
        int numRounds = numTeams - 1; // Total rounds
        int halfSize = numTeams ~/ 2;

        // List<Map<String, dynamic>> rounds = [];

        // Create a list to rotate players
        List<Team> rotation = List.from(teamList);

        for (int round = 0; round < numRounds; round++) {
          List<Map<String, dynamic>> matches = [];

          for (int i = 0; i < halfSize; i++) {
            Team home = rotation[i];
            Team away = rotation[numTeams - 1 - i];

            List<String> tplayerIds = [];
            if (home.playerIdsTeam.isNotEmpty) {
              tplayerIds.addAll(home.playerIdsTeam);
            }
            if (away.playerIdsTeam.isNotEmpty) {
              tplayerIds.addAll(away.playerIdsTeam);
            }
            // if ((home.teamName == 'BYE' &&
            //         away.teamId != finalistTeam.teamId) ||
            //     (away.teamName == 'BYE' &&
            //         home.teamId != finalistTeam.teamId)) {
            //   continue;
            // }

            if (home.playerIdsTeam != ["BYE"] &&
                away.playerIdsTeam != ["BYE"]) {
              matches.add({
                'id': '${group.name}_match_${round + 1}_$i',
                'type': 'singles',
                'status': 'upcoming',
                'playerIds': tplayerIds,
                'team1': home.toMap(),
                'team2': away.toMap(),
                'scores': {home.teamName: 0, away.teamName: 0},
                'winner': '',
                'streamUrl': '',
              });
              // matches.add({
              //   "player1": home,
              //   "player2": away,
              // });
            }
          }

          r.add({
            'id': '${group.name}_round_${round + 1}',
            'name': '${group.name} - Round ${round + 1}',
            "roundNumber": round + 1,
            "matches": matches,
          });

          // Rotate players for next round
          var lastPlayer = rotation.removeLast();
          rotation.insert(1, lastPlayer);
        }
      }

      return r;
    } else // if not singles , then doubles -------------
    {
      List<Map<String, dynamic>> r = [];
      for (var group in groups) {
        List<Team> teamList = List.from(group.teams);

        if (teamList.length.isOdd) {
          teamList.add(
            Team(
              teamId: DateTime.now().millisecondsSinceEpoch.toString(),
              teamName: "BYE",
              playerIdsTeam: ["BYE"],
              played: 0,
              wins: 0,
              draws: 0,
              losses: 0,
              goalsFor: 0,
              goalsAgainst: 0,
            ),
          );
        }

        int numPlayers = teamList.length;
        int numRounds = numPlayers - 1; // Total rounds
        int halfSize = numPlayers ~/ 2;

        // List<Map<String, dynamic>> rounds = [];

        // Create a list to rotate players
        List<Team> rotation = List.from(teamList);

        for (int round = 0; round < numRounds; round++) {
          List<Map<String, dynamic>> matches = [];

          for (int i = 0; i < halfSize; i++) {
            Team home = rotation[i];
            Team away = rotation[numPlayers - 1 - i];

            List<String> tplayerIds = [];
            if (home.playerIdsTeam.isNotEmpty) {
              tplayerIds.addAll(home.playerIdsTeam);
            }
            if (away.playerIdsTeam.isNotEmpty) {
              tplayerIds.addAll(away.playerIdsTeam);
            }
            if (home.playerIdsTeam != ["BYE"] &&
                away.playerIdsTeam != ["BYE"]) {
              matches.add({
                'id': '${group.name}_match_${round + 1}_$i',
                'type': 'doubles',
                'status': 'upcoming',
                'playerIds': tplayerIds,
                'team1': home.toMap(),
                'team2': away.toMap(),
                'scores': {home.teamName: 0, away.teamName: 0},
                'winner': '',
                'streamUrl': '',
              });
            }
          }

          r.add({
            'id': '${group.name}round_${round + 1}',
            'name': '${group.name} - Round ${round + 1}',
            "roundNumber": round + 1,
            "matches": matches,
          });

          // Rotate players for next round
          var lastPlayer = rotation.removeLast();
          rotation.insert(1, lastPlayer);
        }
      }

      return r;
    }
  }

  List<Map<String, dynamic>> _generateRoundRobin(List<Team> teams) {
    if (isDoubles == false) {
      List<Team> teamList = List.from(teams);

      // Add a dummy "BYE" if odd number of players
      bool hasBye = false;
      if (teamList.length.isOdd) {
        teamList.add(
          Team(
            teamId: "bye_1",
            teamName: "BYE",
            playerIdsTeam: ["BYE"],
            played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            goalsFor: 0,
            goalsAgainst: 0,
          ),
        );
        hasBye = true;
      }

      int numPlayers = teamList.length;
      int numRounds = numPlayers - 1; // Total rounds
      int halfSize = numPlayers ~/ 2;

      List<Map<String, dynamic>> rounds = [];

      // Create a list to rotate players
      List<Team> rotation = List.from(teamList);

      for (int round = 0; round < numRounds; round++) {
        List<Map<String, dynamic>> matches = [];

        for (int i = 0; i < halfSize; i++) {
          Team home = rotation[i];
          Team away = rotation[numPlayers - 1 - i];

          List<String> tplayerIds = [];
          if (home.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(home.playerIdsTeam);
          }
          if (away.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(away.playerIdsTeam);
          }

          // Skip matches with BYE
          if (home.playerIdsTeam != ["BYE"] && away.playerIdsTeam != ["BYE"]) {
            matches.add({
              'id': 'match_${round + 1}_$i',
              'type': 'singles',
              'status': 'upcoming',
              'playerIds': tplayerIds,
              'team1': home.toMap(),
              'team2': away.toMap(),
              'scores': {home.teamName: 0, away.teamName: 0},
              'winner': '',
              'streamUrl': '',
            });
          }
        }

        rounds.add({
          'id': 'round_${round + 1}',
          'name': 'Round ${round + 1}',
          "roundNumber": round + 1,
          "matches": matches,
        });

        // Rotate players for next round
        var lastPlayer = rotation.removeLast();
        rotation.insert(1, lastPlayer);
      }

      return rounds;
    }
    // chosen finalist ---------------------------
    else if (finalistTeam.teamId != "not_selected") {
      List<Team> teamList = List.from(teams);

      teamList.removeWhere((team) => team.teamId == finalistTeam.teamId);

      if (teamList.length.isOdd) {
        teamList.add(
          Team(
            teamId: DateTime.now().millisecondsSinceEpoch.toString(),
            teamName: "BYE",
            playerIdsTeam: ["BYE"],
            played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            goalsFor: 0,
            goalsAgainst: 0,
          ),
        );
      }

      int numPlayers = teamList.length;
      int numRounds = numPlayers - 1; // Total rounds
      int halfSize = numPlayers ~/ 2;

      List<Map<String, dynamic>> rounds = [];

      // Create a list to rotate players
      List<Team> rotation = List.from(teamList);

      for (int round = 0; round < numRounds; round++) {
        List<Map<String, dynamic>> matches = [];

        for (int i = 0; i < halfSize; i++) {
          Team home = rotation[i];
          Team away = rotation[numPlayers - 1 - i];

          List<String> tplayerIds = [];
          if (home.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(home.playerIdsTeam);
          }
          if (away.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(away.playerIdsTeam);
          }
          if ((home.teamName == 'BYE' && away.teamId != finalistTeam.teamId) ||
              (away.teamName == 'BYE' && home.teamId != finalistTeam.teamId)) {
            continue;
          }

          if (home.playerIdsTeam != ["BYE"] && away.playerIdsTeam != ["BYE"]) {
            matches.add({
              'id': 'match_${round + 1}_$i',
              'type': 'singles',
              'status': 'upcoming',
              'playerIds': tplayerIds,
              'team1': home.toMap(),
              'team2': away.toMap(),
              'scores': {home.teamName: 0, away.teamName: 0},
              'winner': '',
              'streamUrl': '',
            });
            // matches.add({
            //   "player1": home,
            //   "player2": away,
            // });
          }
        }

        rounds.add({
          'id': 'round_${round + 1}',
          'name': 'Round ${round + 1}',
          "roundNumber": round + 1,
          "matches": matches,
        });

        // Rotate players for next round
        var lastPlayer = rotation.removeLast();
        rotation.insert(1, lastPlayer);
      }

      return rounds;
    } else // if not singles , then doubles -------------
    {
      List<Team> teamList = List.from(teams);

      if (teamList.length.isOdd) {
        teamList.add(
          Team(
            teamId: DateTime.now().millisecondsSinceEpoch.toString(),
            teamName: "BYE",
            playerIdsTeam: ["BYE"],
            played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            goalsFor: 0,
            goalsAgainst: 0,
          ),
        );
      }

      int numPlayers = teamList.length;
      int numRounds = numPlayers - 1; // Total rounds
      int halfSize = numPlayers ~/ 2;

      List<Map<String, dynamic>> rounds = [];

      // Create a list to rotate players
      List<Team> rotation = List.from(teamList);

      for (int round = 0; round < numRounds; round++) {
        List<Map<String, dynamic>> matches = [];

        for (int i = 0; i < halfSize; i++) {
          Team home = rotation[i];
          Team away = rotation[numPlayers - 1 - i];

          List<String> tplayerIds = [];
          if (home.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(home.playerIdsTeam);
          }
          if (away.playerIdsTeam.isNotEmpty) {
            tplayerIds.addAll(away.playerIdsTeam);
          }
          if (home.playerIdsTeam != ["BYE"] && away.playerIdsTeam != ["BYE"]) {
            matches.add({
              'id': 'match_${round + 1}_$i',
              'type': 'doubles',
              'status': 'upcoming',
              'playerIds': tplayerIds,
              'team1': home.toMap(),
              'team2': away.toMap(),
              'scores': {home.teamName: 0, away.teamName: 0},
              'winner': '',
              'streamUrl': '',
            });
            // matches.add({
            //   "player1": home,
            //   "player2": away,
            // });
          }
        }

        rounds.add({
          'id': 'round_${round + 1}',
          'name': 'Round ${round + 1}',
          "roundNumber": round + 1,
          "matches": matches,
        });

        // Rotate players for next round
        var lastPlayer = rotation.removeLast();
        rotation.insert(1, lastPlayer);
      }

      return rounds;
    }
  }

  List<Map<String, dynamic>> _generateSingleElimination(List<String> players) {
    List<Map<String, dynamic>> rounds = [];
    int roundNumber = 1;
    List<String> currentRoundPlayers = List.from(players);

    while (currentRoundPlayers.length > 1) {
      List<Map<String, dynamic>> matches = [];

      for (int i = 0; i < currentRoundPlayers.length; i += 2) {
        List<String> matchPlayers = [];
        if (i + 1 < currentRoundPlayers.length) {
          matchPlayers = [currentRoundPlayers[i], currentRoundPlayers[i + 1]];
        } else {
          // Odd number of players, auto-advance
          matchPlayers = [currentRoundPlayers[i]];
        }

        matches.add({
          'type': 'doubles',
          'status': 'upcoming',
          'playerIds': matchPlayers,
          'scores': {'team1': 0, 'team2': 0},
          'winner': '',
          'streamUrl': '',
        });
      }

      rounds.add({
        'name': 'Round $roundNumber',
        'roundNumber': roundNumber,
        'matches': matches,
      });

      // Prepare winners for next round (will populate later)
      currentRoundPlayers = [];
      roundNumber++;
    }

    return rounds;
  }

  List<Map<String, dynamic>> _generateDoubleElimination(List<String> players) {
    List<Map<String, dynamic>> rounds = [];

    List<Map<String, dynamic>> matches = [];

    for (int i = 0; i < players.length; i += 2) {
      List<String> matchPlayers = [];
      if (i + 1 < players.length) {
        matchPlayers = [players[i], players[i + 1]];
      } else {
        // Odd number of players, auto-advance
        matchPlayers = [players[i]];
      }

      matches.add({
        'type': 'singles',
        'status': 'upcoming',
        'playerIds': matchPlayers,
        'scores': {'team1': 0, 'team2': 0},
        'winner': '',
        'streamUrl': '',
      });
    }

    rounds.add({
      'name': 'Winners Round 1',
      'roundNumber': 1,
      'matches': matches,
    });

    return rounds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tournament')),
      body: arePlayersSelected == true
          ? showBody()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  const Text(
                    'Select Players:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildPlayerList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        arePlayersSelected = true;
                      });
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget showBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tournament Name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(
                  value: 'Round Robin',
                  child: Text('Round Robin'),
                ),
                DropdownMenuItem(
                  value: 'Group Format',
                  child: Text('Group Format'),
                ),
                // DropdownMenuItem(
                //   value: 'Single Elimination',
                //   child: Text('Single Elimination'),
                // ),
                // DropdownMenuItem(
                //   value: 'Double Elimination',
                //   child: Text('Double Elimination'),
                // ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Tournament Type'),
              validator: (value) =>
                  value == null ? 'Select a tournament type' : null,
            ),
            const SizedBox(height: 10),
            // add a toggle for doubles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Doubles'),
                Switch(
                  value: isDoubles,
                  onChanged: (value) {
                    setState(() {
                      isDoubles = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Custom Teams'),
                Switch(
                  value: isCustomTeams,
                  onChanged: (value) {
                    setState(() {
                      isCustomTeams = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose Finalist'),
                Switch(
                  value: choosingFinalist,
                  onChanged: (value) {
                    setState(() {
                      choosingFinalist = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Make Groups'),
                Switch(
                  value: makeGroups,
                  onChanged: (value) {
                    setState(() {
                      makeGroups = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a date' : null,
            ),
            if (choosingFinalist == true)
              // Display the custom teams created is ListView
              Column(
                children: teams.map((team) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(team.teamName),
                        Spacer(),

                        // if (teams.length.isOdd)
                        Checkbox(
                          value: team.teamId == finalistTeam.teamId,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                finalistTeam = team;
                                finalistTeam = Team(
                                  teamId: team.teamId,
                                  teamName: team.teamName,
                                  playerIdsTeam: team.playerIdsTeam,
                                  played: team.played,
                                  wins: 20,
                                  draws: team.draws,
                                  losses: team.losses,
                                  goalsFor: team.goalsFor,
                                  goalsAgainst: team.goalsAgainst,
                                );
                              } else {
                                finalistTeam = Team(
                                  teamId: "bye_1",
                                  teamName: "BYE",
                                  playerIdsTeam: ["BYE"],
                                  played: 0,
                                  wins: 0,
                                  draws: 0,
                                  losses: 0,
                                  goalsFor: 0,
                                  goalsAgainst: 0,
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // const SizedBox(height: 10),
            // if (isCustomTeams == false) const Text('Select Players:'),
            // if (isCustomTeams == false) _buildPlayerList(),
            const SizedBox(height: 20),
            if (isCustomTeams == true)
              ElevatedButton(
                onPressed: () async {
                  // Navigate to Custom Teams Page

                  teams = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateTeamsPage(selectedPlayers: _selectedPlayerIds),
                    ),
                  );
                  if (teams.isNotEmpty) {
                    teamsCreated = true;
                  }
                },
                child: Text('Create Custom Teams'),
              ),
            if (isCustomTeams == false)
              ElevatedButton(
                onPressed: () {
                  teamsCreated = true;
                  if (_selectedPlayerIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select players to form teams.'),
                      ),
                    );
                    return;
                  } else {
                    _showTeamDialog(context);
                  }
                },
                child: Text(isDoubles ? 'Generate Teams' : 'Shuffle Players'),
              ),
            const SizedBox(height: 20),
            if (makeGroups == true)
              ElevatedButton(
                onPressed: () async {
                  // Navigate to Custom Teams Page

                  groups = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupingWidget(teams: teams),
                    ),
                  );
                },
                child: Text('Create Groups '),
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      if (teamsCreated == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please generate teams first.'),
                          ),
                        );
                        return;
                      } else {
                        _createTournament();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Create Tournament'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('players').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final players = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            final playerId = player.id;
            final playerName = player['name'];

            return CheckboxListTile(
              title: Text(playerName),
              value: _selectedPlayerIds.contains(playerId),
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked == true) {
                    _selectedPlayerIds.add(playerId);
                  } else {
                    _selectedPlayerIds.remove(playerId);
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  // function to get all players from the firestore
  Future<List<String>> _getAllPlayers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('players')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<String> getPlayerName(String playerId) async {
    final firestore = FirebaseFirestore.instance;
    // Map<String, String> playerNames = {};
    String name = '';

    try {
      DocumentSnapshot doc = await firestore
          .collection('players')
          .doc(playerId)
          .get();
      if (doc.exists) {
        name = doc.get('name');
        // playerNames[playerId] = name;
      } else {
        // playerNames[playerId] = 'Unknown'; // fallback if player not found
        name = 'Unknown';
      }
    } catch (e) {
      print('Error fetching player names: $e');
    }

    return name;
  }
}
