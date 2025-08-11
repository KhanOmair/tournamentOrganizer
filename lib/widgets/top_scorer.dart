import 'package:flutter/material.dart';
import 'package:tourney_app/models/tournament.dart';

class TopScorerWidget extends StatelessWidget {
  final List<TopScorer> topScorers;

  const TopScorerWidget({Key? key, required this.topScorers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topScorers.isEmpty) {
      return Text('No top scorers yet.');
    }

    // Find the player(s) with max goals
    int maxGoals = topScorers
        .map((e) => e.goals)
        .reduce((a, b) => a > b ? a : b);

    final leaders = topScorers
        .where((scorer) => scorer.goals == maxGoals)
        .toList();

    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Top Scorer${leaders.length > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...leaders.map(
              (scorer) => ListTile(
                leading: CircleAvatar(
                  child: Text(
                    scorer.name.isNotEmpty ? scorer.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(scorer.name),
                trailing: Text(
                  '${scorer.goals} goal${scorer.goals == 1 ? '' : 's'}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
