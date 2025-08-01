import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/match_crud.dart';
import 'package:tourney_app/widgets/podium_widget.dart';
import 'package:tourney_app/widgets/tourney_rounds_widget.dart';
import 'package:tourney_app/widgets/standings_table.dart';

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;
  final bool isAdmin;
  const TournamentDetailPage({
    Key? key,
    required this.tournament,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _TournamentDetailPageState createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Player loggedInPlayer;

  int get matchesLeft {
    int matches = 0;
    for (var round in widget.tournament.rounds) {
      for (var match in round.matchIds) {
        if (match.status != 'completed') {
          matches++;
        }
      }
    }
    return matches;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showAddMatchDialog() {
    final roundNameController = TextEditingController();
    Team? selectedTeam1;
    Team? selectedTeam2;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Match'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: roundNameController,
                    decoration: const InputDecoration(labelText: 'Round Name'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Team>(
                    hint: const Text("Select Home Team"),
                    value: selectedTeam1,
                    items: widget.tournament.teams.map((team) {
                      return DropdownMenuItem(
                        value: team,
                        child: Text(team.teamName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedTeam1 = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Team>(
                    hint: const Text("Select Away Team"),
                    value: selectedTeam2,
                    items: widget.tournament.teams.map((team) {
                      return DropdownMenuItem(
                        value: team,
                        child: Text(team.teamName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedTeam2 = value);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final roundName = roundNameController.text.trim();

              if (roundName.isEmpty ||
                  selectedTeam1 == null ||
                  selectedTeam2 == null ||
                  selectedTeam1 == selectedTeam2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please complete all fields and select different teams.',
                    ),
                  ),
                );
                return;
              } else {
                // Call the function to create a match
                createMatch(
                      tournamentId: widget.tournament.id,
                      roundName: roundName,
                      homeTeam: selectedTeam1!,
                      awayTeam: selectedTeam2!,
                    )
                    .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Match created successfully!'),
                        ),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    })
                    .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating match: $error')),
                      );
                    });
              }

              // onMatchCreated(roundName, selectedTeam1!, selectedTeam2!);
            },
            child: const Text('Create Match'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Details'),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // open dialog box to add a new match to the tournament
                showAddMatchDialog();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Row with CircleAvatar and Tournament Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // CircleAvatar(
                  //   radius: 30,
                  //   // backgroundImage: NetworkImage(widget.tournamentImageUrl),
                  //   backgroundColor: Colors.grey.shade300,
                  // ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.tournament.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.deepOrangeAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrangeAccent,
              tabs: const [
                Tab(text: "Table"),
                Tab(text: "Matches"),
                Tab(text: "Teams"),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ------  Table Tab UI  -------
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tournaments')
                          .doc(widget.tournament.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final tournamentMap =
                            snapshot.data!.data() as Map<String, dynamic>;
                        Tournament mtournament = Tournament.fromFirestore(
                          tournamentMap,
                          snapshot.data!.id,
                        );

                        return StandingsTable(teams: mtournament.teams);
                      },
                    ),
                  ),
                  //  ------   Matches Tab UI   -------
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tournaments')
                          .doc(widget.tournament.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final tournamentMap =
                            snapshot.data!.data() as Map<String, dynamic>;
                        Tournament tournament = Tournament.fromFirestore(
                          tournamentMap,
                          snapshot.data!.id,
                        );
                        print(tournament);

                        // Build your tournament details UI
                        return TournamentRoundsWidget(
                          tournament: tournament,
                          isAdmin: widget.isAdmin,
                        );
                      },
                    ),
                  ),
                  // -------  Teams Tab UI -------
                  Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tournaments')
                          .doc(widget.tournament.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final tournamentMap =
                            snapshot.data!.data() as Map<String, dynamic>;
                        Tournament tournament = Tournament.fromFirestore(
                          tournamentMap,
                          snapshot.data!.id,
                        );
                        print(tournament);

                        // Build your tournament details UI
                        return PodiumWidget(
                          teams: tournament.teams,
                          groups: tournament.groups,
                        );
                      },
                    ),
                    // child: Text(
                    //   "Teams UI Here",
                    //   style: TextStyle(fontSize: 18, color: Colors.grey),
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.isAdmin &&
              matchesLeft == 0
              // &&
              // _tabController.index == 1
              &&
              widget.tournament.rounds.last.name != 'Final'
          ? Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.deepOrangeAccent,
                label: const Text('Create Final'),
                onPressed: () async {
                  try {
                    await createFinalMatch(widget.tournament.id);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating final match: $e')),
                    );
                  }
                },
              ),
            )
          : SizedBox.shrink(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
