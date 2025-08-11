import 'package:flutter/material.dart';
import 'package:tourney_app/models/tournament.dart';

class TopScorerWidget extends StatelessWidget {
  final List<TopScorer> topScorers;

  const TopScorerWidget({Key? key, required this.topScorers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topScorers.isEmpty) {
      return const Text('No top scorers yet.');
    }

    // Sort all players by goals (highest first)
    final sortedScorers = [...topScorers]
      ..sort((a, b) => b.goals.compareTo(a.goals));

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Top Scorers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sortedScorers.map(
              (scorer) => ListTile(
                leading: CircleAvatar(
                  child: Text(
                    scorer.name.isNotEmpty ? scorer.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(scorer.name),
                trailing: Text(
                  '${scorer.goals} goal${scorer.goals == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
