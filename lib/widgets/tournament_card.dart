import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/tournament_detail_page.dart';
import 'package:tourney_app/utils/tournament_crud.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });

  int get matchesLeft {
    int matches = 0;
    for (var round in tournament.rounds) {
      for (var match in round.matchIds) {
        if (match.status != 'completed') {
          matches++;
        }
      }
    }
    return matches;
  }

  Future<void> participateInTournament({
    required String tournamentId,
    required String playerId,
  }) async {
    final tournamentRef = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId);

    final playerRef = FirebaseFirestore.instance
        .collection('players')
        .doc(playerId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tournamentSnap = await transaction.get(tournamentRef);
        final playerSnap = await transaction.get(playerRef);

        if (!tournamentSnap.exists) {
          throw Exception('Tournament not found');
        }

        if (!playerSnap.exists) {
          throw Exception('Player not found');
        }

        List<dynamic> participants =
            tournamentSnap['participants'] ?? <String>[];

        if (participants.contains(playerId)) {
          throw Exception('You have already joined this tournament');
        }

        // Add player to tournament participants
        participants.add(playerId);
        transaction.update(tournamentRef, {'participants': participants});

        // Increment player's tournamentsPlayed count
        int tournamentsPlayed = playerSnap['tournamentsPlayed'] ?? 0;
        transaction.update(playerRef, {
          'tournamentsPlayed': tournamentsPlayed + 1,
        });
      });

      print('✅ Successfully joined tournament!');
    } catch (e) {
      print('❌ Error joining tournament: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Icon and Tournament Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const Icon(Icons.sports_esports, color: Colors.deepOrange),
                CircleAvatar(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second Row: tourney info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$matchesLeft',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'matches left',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tournament.playerIds.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'players',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'type',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Remove tournament Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAdmin)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () async {
                        try {
                          await deleteTournament(tournament.id);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting tournament: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                Spacer(),
                // view tournament details button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your navigation or action here

                      if (tournament.status == 'upcoming') {
                        return;
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentDetailPage(
                              tournament: tournament,
                              isAdmin: isAdmin,
                            ),
                          ),
                        );
                        print('Viewing ${tournament.name}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      tournament.status == 'upcoming'
                          ? 'Starting at ${DateFormat('d MMMM y').format(tournament.startDate)}'
                          : 'View',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                Spacer(),
                // change status button
                if (isAdmin && tournament.status == 'upcoming')
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        try {
                          await updatetTournamentStatus(
                            tournamentId: tournament.id,
                            status: 'ongoing',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error starting tournament: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
