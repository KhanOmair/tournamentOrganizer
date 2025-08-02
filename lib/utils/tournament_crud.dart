// add a fucntion to change the status of the tournament to a started
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updatetTournamentStatus({
  String? tournamentId,
  String? status,
}) async {
  final tournamentRef = FirebaseFirestore.instance
      .collection('tournaments')
      .doc(tournamentId);

  try {
    await tournamentRef.update({'status': status});
    print('Tournament status updated to $status successfully ✅');
  } catch (e) {
    print('Error updating tournament status: $e');
    throw e; // Re-throw the error for further handling if needed
  }
}

Future<void> deleteTournament(String tournamentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tournamentId)
        .delete();

    print('Tournament deleted successfully');
  } catch (e) {
    print('Error deleting tournament: $e');
    // You can show a snackbar or alert here too
  }
}

Future<void> updateTournamentsPlayedForPlayers(List<String> playerIds) async {
  final playersCollection = FirebaseFirestore.instance.collection('players');

  for (String playerId in playerIds) {
    final playerDocRef = playersCollection.doc(playerId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(playerDocRef);

      if (snapshot.exists) {
        final data = snapshot.data();
        final globalStats = data?['globalStats'] ?? {};

        final currentTournamentsPlayed = globalStats['tournamentsPlayed'] ?? 0;

        transaction.update(playerDocRef, {
          'globalStats.tournamentsPlayed': currentTournamentsPlayed + 1,
        });
      } else {
        // Optional: Create player doc with initial globalStats
        transaction.set(playerDocRef, {
          'globalStats': {
            'matchesPlayed': 0,
            'wins': 0,
            'losses': 0,
            'tournamentsPlayed': 1,
          },
        });
      }
    });
  }
}
