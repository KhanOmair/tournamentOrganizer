import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/match_crud.dart';
import 'package:url_launcher/url_launcher.dart';

class TournamentRoundsWidget extends StatefulWidget {
  final Tournament tournament;
  final bool isAdmin;

  const TournamentRoundsWidget({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });

  @override
  State<TournamentRoundsWidget> createState() => _TournamentRoundsWidgetState();
}

class _TournamentRoundsWidgetState extends State<TournamentRoundsWidget> {
  String newTeam1 = '';
  String newTeam2 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.tournament.rounds.length,
        itemBuilder: (context, index) {
          final round = widget.tournament.rounds[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                round.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: round.matchIds.map((match) {
                return Card(
                  color: (match.status == 'completed')
                      ? Colors.green[50]
                      : null,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    // leading: CircleAvatar(
                    //   backgroundColor: _getStatusColor(match.status),
                    //   child: Icon(
                    //     match.status == 'completed'
                    //         ? Icons.check
                    //         : Icons.schedule,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    title: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                match.team1.teamName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${match.scores.team1}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('vs', style: TextStyle(fontSize: 16)),
                              Text(':', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.team2.teamName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${match.scores.team2}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    subtitle: // Display stream URL if available
                    match.streamUrl.trim().isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri.parse(match.streamUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16,
                                top: 16,
                                bottom: 2,
                              ),
                              child: Center(
                                child: Text(
                                  'Stream URL: ${match.streamUrl}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,

                    trailing: widget.isAdmin
                        ? Icon(Icons.edit, color: Colors.grey)
                        : null,
                    onTap: () {
                      String streamUrl = '';
                      if (widget.isAdmin) {
                        int team1Score = match.scores.team1;
                        int team2Score = match.scores.team2;
                         List goals = [0, 0, 0, 0];
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool changingTeams = false;
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Center(child: Text('Edit Scores')),
                                  content: SizedBox(
                                    width: 500,
                                    // height: 300,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Text(match.team1.teamName),
                                                  SizedBox(height: 8),
                                                  TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: 'Score',
                                                    ),
                                                    onChanged: (value) {
                                                      team1Score =
                                                          int.tryParse(value) ??
                                                          0;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Text(match.team2.teamName),
                                                  SizedBox(height: 8),
                                                  TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: 'Score',
                                                    ),
                                                    onChanged: (value) {
                                                      team2Score =
                                                          int.tryParse(value) ??
                                                          0;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                         if (widget.tournament.sport == 'fifa' &&
                                            !match.playerIds.contains('BYE'))
                                          SizedBox(height: 16),
                                        if (widget.tournament.sport == 'fifa' &&
                                            !match.playerIds.contains('BYE'))
                                          Text(
                                            'Goals Scored',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        // SizedBox(height: 12),
                                        if (widget.tournament.sport == 'fifa' &&
                                            !match.playerIds.contains('BYE'))
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: match.playerIds.length,
                                              itemBuilder: (context, index) {
                                                var scorer = widget
                                                    .tournament
                                                    .topScorers
                                                    .firstWhere(
                                                      (scorer) =>
                                                          scorer.id ==
                                                          match
                                                              .playerIds[index],
                                                      // orElse: () => null,
                                                    );

                                                return Card(
                                                  child: ListTile(
                                                    title: Text(scorer.name),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.remove,
                                                          ),
                                                          onPressed: () async {
                                                            // addPlayerGoal(
                                                            //   tournamentId: widget
                                                            //       .tournament
                                                            //       .id,
                                                            //   goals: -1,

                                                            //   playerId: scorer.id,
                                                            //   playerName:
                                                            //       scorer.name,
                                                            // );
                                                            setState(() {
                                                              goals[index]--;
                                                            });

                                                            await addPlayerGoal(
                                                              tournamentId:
                                                                  widget
                                                                      .tournament
                                                                      .id,
                                                              playerId:
                                                                  scorer.id,
                                                              goals: -1,
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          '${goals[index]}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.add,
                                                          ),
                                                          onPressed: () async {
                                                            // addPlayerGoal(
                                                            //   tournamentId: widget
                                                            //       .tournament
                                                            //       .id,
                                                            //   goals: -1,

                                                            //   playerId: scorer.id,
                                                            //   playerName:
                                                            //       scorer.name,
                                                            // );
                                                            setState(() {
                                                              goals[index]++;
                                                            });
                                                            await addPlayerGoal(
                                                              tournamentId:
                                                                  widget
                                                                      .tournament
                                                                      .id,
                                                              playerId:
                                                                  scorer.id,
                                                              goals: 1,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Text(
                                              'Change Teams',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Switch(
                                              value: changingTeams,
                                              onChanged: (value) {
                                                setState(() {
                                                  changingTeams = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        if (changingTeams)
                                          Text(
                                            'Edit Teams',
                                            style: TextStyle(fontSize: 16),
                                          ),

                                        SizedBox(width: 16),

                                        if (changingTeams)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // dropdown for team1
                                              DropdownButton<String>(
                                                value: match.team1.teamId,
                                                items: widget.tournament.teams
                                                    .map(
                                                      (team) =>
                                                          DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: team.teamId,
                                                            child: Text(
                                                              team.teamName,
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      newTeam1 = value;
                                                    });
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 16),
                                              // dropdown for team2
                                              DropdownButton<String>(
                                                value: match.team2.teamId,
                                                items: widget.tournament.teams
                                                    .map(
                                                      (team) =>
                                                          DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: team.teamId,
                                                            child: Text(
                                                              team.teamName,
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      newTeam2 = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'Update the Stream Url (if any)',
                                          ),
                                          onChanged: (value) {
                                            streamUrl = value;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (changingTeams) {
                                          if (streamUrl.trim().isNotEmpty) {
                                            // Update stream URL logic
                                            await updateMatchStreamUrl(
                                              tournamentId:
                                                  widget.tournament.id,
                                              roundId: round.id,
                                              matchId: match.id,
                                              streamUrl: streamUrl,
                                            );
                                          }
                                          // Update teams logic
                                          await updateMatchTeams(
                                            tournamentId: widget.tournament.id,
                                            roundId: round.id,
                                            matchId: match.id,
                                            newTeam1Id: newTeam1,
                                            newTeam2Id: newTeam2,
                                          );
                                        }
                                        // Save scores logic
                                        else {
                                          if (streamUrl.trim().isNotEmpty) {
                                            // Update stream URL logic
                                            await updateMatchStreamUrl(
                                              tournamentId:
                                                  widget.tournament.id,
                                              roundId: round.id,
                                              matchId: match.id,
                                              streamUrl: streamUrl,
                                            );
                                          }
                                          if (match.winner.trim().isEmpty) {
                                            await updateMatchScore(
                                              tournamentId:
                                                  widget.tournament.id,
                                              roundId: round.id,
                                              matchId: match.id,
                                              team1Score: team1Score,
                                              team2Score: team2Score,
                                            );
                                          } else {
                                            print('Not Updating ');
                                            // Navigator.of(context).pop();
                                          }
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
