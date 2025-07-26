
import 'package:tourney_app/models/match.dart';

class Round {
  final String id;
  final String name; // e.g., Quarter Finals
  final int roundNumber;
  final List<GameMatch> matchIds; // List of match IDs in this round

  Round({
    required this.id,
    required this.name,
    required this.roundNumber,
    this.matchIds = const [],
  });

  factory Round.fromFirestore(Map<String, dynamic> data, String docId) {
    return Round(
      id: docId,
      name: data['name'] ?? '',
      roundNumber: data['roundNumber'] ?? 0,
      matchIds: List<GameMatch>.from(
        (data['matches'] as List<dynamic>?)
            ?.map((matchData) => GameMatch.fromFirestore(matchData, matchData['id']))
            ?? [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'roundNumber': roundNumber,
      'matchIds': matchIds.map((match) => match.toFirestore()).toList(),
    };
  }
}
