import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tourney_app/models/match.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/round.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/create_tournament_page.dart';
import 'package:tourney_app/widgets/match_card.dart';
import 'package:tourney_app/widgets/player_card.dart';
import 'package:tourney_app/widgets/tournament_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tournament> fetchedTournaments = [];
  Player? loggedInPlayer;
  late Future<void> _initFuture;

  final List<Tournament> tournaments = [
    Tournament(
      participants: [],
      teams: [
        Team(
          teamId: 'team1',
          teamName: 'teamName',
          playerIdsTeam: ['playerIdsTeam', 'dfvjvbvf'],
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goalsFor: 0,
          goalsAgainst: 0,
        ),
        Team(
          teamId: 'team2',
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goalsFor: 0,
          goalsAgainst: 0,
          teamName: 'teamName',
          playerIdsTeam: ['playerIdsTeam', 'dfvjvbvf'],
        ),
        Team(
          teamId: 'team2',
          played: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          goalsFor: 0,
          goalsAgainst: 0,
          teamName: 'teamName',
          playerIdsTeam: ['playerIdsTeam', 'dfvjvbvf'],
        ),
      ],
      id: '3435y4',
      name: 'name',
      type: 'roundRobin',
      status: 'ongoing',
      startDate: DateTime(2025, 7, 9),
      playerIds: ['dfrg', 'dfrg', 'dfdffgdg'],
      rounds: [
        Round(
          id: 'round1',
          name: 'Round 1',
          roundNumber: 1,
          matchIds: [
            GameMatch(
              id: 'match1',
              type: 'singles',
              status: 'completed',
              playerIds: ['player1', 'player2'],
              scores: MatchScore(team1: 3, team2: 1),
              winner: 'team1',
              team1: Team(
                teamId: 'team1',
                played: 0,
                wins: 0,
                draws: 0,
                losses: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                teamName: 'team1',
                playerIdsTeam: ['player1', 'player2'],
              ),
              team2: Team(
                teamId: 'team2',
                played: 0,
                wins: 0,
                draws: 0,
                losses: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                teamName: 'team2',
                playerIdsTeam: ['player3', 'player4'],
              ),
            ),
            GameMatch(
              id: 'match2',
              type: 'doubles',
              status: 'upcoming',
              playerIds: ['player3', 'player4'],
              scores: MatchScore(team1: 2, team2: 2),
              winner: '',
              team1: Team(
                teamId: 'team1',
                played: 0,
                wins: 0,
                draws: 0,
                losses: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                teamName: 'team2',
                playerIdsTeam: ['player3', 'player4'],
              ),
              team2: Team(
                teamId: 'team2',
                played: 0,
                wins: 0,
                draws: 0,
                losses: 0,
                goalsFor: 0,
                goalsAgainst: 0,
                teamName: 'team1',
                playerIdsTeam: ['player1', 'player2'],
              ),
            ),
          ],
        ),
      ],
    ),
  ];
  @override
  void initState() {
    super.initState();
    _initFuture = init();
  }

  // init method to fetch tournaments from Firestore
  // Future<List<Tournament>> init() async {
  //   // Fetch tournaments from Firestore
  //   final tournamentCollection = FirebaseFirestore.instance.collection(
  //     'tournaments',
  //   );
  //   final tournamentDocs = await tournamentCollection.get();

  //   // Check if the user is logged in and fetch their data
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await FirebaseFirestore.instance
  //         .collection('players')
  //         .doc(user.uid)
  //         .get()
  //         .then((userDoc) {
  //           if (userDoc.exists) {
  //             loggedInPlayer = Player.fromFirestore(
  //               userDoc.data()!,
  //               userDoc.id,
  //             );
  //             print('Logged in player: ${loggedInPlayer!.name}');
  //           }
  //         });
  //   } else {
  //     throw Exception('User not found');
  //   }

  //   setState(() {
  //     fetchedTournaments = tournamentDocs.docs.map((doc) {
  //       return Tournament.fromFirestore(doc.data(), doc.id);
  //     }).toList();
  //   });
  //   return fetchedTournaments;
  // }

  Future<List<Tournament>> init() async {
    final tournamentCollection = FirebaseFirestore.instance.collection(
      'tournaments',
    );
    final tournamentDocs = await tournamentCollection.get();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('players')
          .doc(user.uid)
          .get()
          .then((userDoc) {
            if (userDoc.exists) {
              loggedInPlayer = Player.fromFirestore(
                userDoc.data()!,
                userDoc.id,
              );
              print('Logged in player: ${loggedInPlayer!.name}');
            }
          });
    } else {
      throw Exception('User not found');
    }

    // ✅ Check if the widget is still mounted
    if (!mounted) return [];

    setState(() {
      fetchedTournaments = tournamentDocs.docs.map((doc) {
        return Tournament.fromFirestore(doc.data(), doc.id);
      }).toList();
    });

    return fetchedTournaments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Tournament>>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .snapshots()
            .map((snapshot) {
              return snapshot.docs.map((doc) {
                return Tournament.fromFirestore(doc.data(), doc.id);
              }).toList();
            }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || fetchedTournaments.isEmpty) {
            return const Center(child: Text('No tournaments found.'));
          } else {
            fetchedTournaments = snapshot.data!;
            final upcomingTournaments = fetchedTournaments
                .where((t) => t.status.toLowerCase() == 'upcoming')
                .toList();
            final completedTournaments = fetchedTournaments
                .where((t) => t.status.toLowerCase() == 'completed')
                .toList();
            final ongoingTournaments = fetchedTournaments
                .where((t) => t.status.toLowerCase() == 'ongoing')
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;

                // Desktop layout
                if (width > 900) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: const [
                        // TournamentCard(),
                        PlayerCard(),
                        MatchCard(),
                        // TournamentBracketTree(
                        //   tournamentId: 'ILUZobyQXe1Iw3OYBnDx',
                        // ),
                      ],
                    ),
                  );
                }
                // Tablet layout
                else if (width > 600) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: const [
                        // TournamentCard(),
                        Text(
                          'Upcoming Matches Tablet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PlayerCard(),
                        MatchCard(),
                      ],
                    ),
                  );
                }
                // Mobile layout
                else {
                  return SafeArea(
                    // wrap this with a future builder to fetch tournaments
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Welcome Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            color: Colors.deepOrangeAccent,
                            child: const Center(
                              child: Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // List of Tournaments -  ongoing tournaments
                          // Ongoing Tournaments Text
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Ongoing Tournaments",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (ongoingTournaments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('No ongoing tournaments'),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: ongoingTournaments.length,
                                itemBuilder: (context, index) {
                                  return TournamentCard(
                                    tournament: ongoingTournaments[index],
                                    isAdmin: loggedInPlayer?.isAdmin ?? false,
                                  );
                                },
                              ),
                            ),
                          // -- upcoming tournaments
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Upcoming Tournaments",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (upcomingTournaments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('No upcoming tournaments'),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: upcomingTournaments.length,
                                itemBuilder: (context, index) {
                                  return TournamentCard(
                                    tournament: upcomingTournaments[0],
                                    isAdmin: loggedInPlayer?.isAdmin ?? false,
                                  );
                                },
                              ),
                            ),
                          //  -- completed tournaments
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Completed Tournaments",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (completedTournaments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('No completed tournaments'),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: completedTournaments.length,
                                itemBuilder: (context, index) {
                                  return TournamentCard(
                                    tournament: completedTournaments[index],
                                    isAdmin: loggedInPlayer?.isAdmin ?? false,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.green,
        onPressed: () {
          // Will connect to Add Tournament/Player later
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTournamentPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
