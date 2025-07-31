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
        final currentCount = snapshot.data()?['tournamentsPlayed'] ?? 0;
        transaction.update(playerDocRef, {
          'tournamentsPlayed': currentCount + 1,
        });
      } else {
        // Optional: Create the player document if it doesn't exist
        transaction.set(playerDocRef, {'tournamentsPlayed': 1});
      }
    });
  }
}
