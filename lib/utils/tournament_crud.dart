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
