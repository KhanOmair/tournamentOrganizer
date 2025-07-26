import 'package:flutter/material.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/match_crud.dart';

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

                    trailing: Icon(Icons.edit, color: Colors.grey),
                    onTap: () {
                      if (widget.isAdmin) {
                        int team1Score = match.scores.team1;
                        int team2Score = match.scores.team2;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Center(child: Text('Edit Scores')),
                            content: SizedBox(
                              width: 300,
                              height: 80,
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 100,
                                    child: Column(
                                      children: [
                                        Text(match.team1.teamName),
                                        TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Score',
                                          ),
                                          onChanged: (value) {
                                            team1Score =
                                                int.tryParse(value) ?? 0;
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
                                        TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Score',
                                          ),
                                          onChanged: (value) {
                                            team2Score =
                                                int.tryParse(value) ?? 0;
                                          },
                                        ),
                                      ],
                                    ),
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
                                  // Save scores logic
                                  await updateMatchScore(
                                    tournamentId: widget.tournament.id,
                                    roundId: round.id,
                                    matchId: match.id,
                                    team1Score: team1Score,
                                    team2Score: team2Score,
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
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
