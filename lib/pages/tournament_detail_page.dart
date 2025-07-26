import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Container with Back Arrow and Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: Colors.deepOrangeAccent,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Tournament Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

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
                        return PodiumWidget(teams: tournament.teams);
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
