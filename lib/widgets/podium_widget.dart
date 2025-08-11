import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/widgets/top_scorer.dart';

class PodiumWidget extends StatelessWidget {
  final List<Team> teams;
  final List<Group> groups;
  final List<TopScorer> topScorers;
  const PodiumWidget({
    Key? key,
    required this.teams,
    required this.groups,
    required this.topScorers,
  }) : super(key: key);

  List<Team> _sortTeams(List<Team> unsortedTeams) {
    final sorted = List<Team>.from(unsortedTeams);
    sorted.sort((a, b) {
      // Sort by Points
      if (b.points != a.points) return b.points.compareTo(a.points);

      // If Points equal, sort by Goal Difference
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // If GD equal, sort by Wins
      if (b.wins != a.wins) return b.wins.compareTo(a.wins);

      // If all equal, sort alphabetically
      return a.teamName.compareTo(b.teamName);
    });
    return sorted;
  }

  List<Team> get podiumTeams {
    final sortedTeams = _sortTeams(teams);
    return sortedTeams.take(3).toList(); // Get top 3 teams
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumBlock(
                  position: 2,
                  name: podiumTeams.length > 1
                      ? podiumTeams[1].teamName
                      : 'N/A',
                  size: 120,
                  color: Colors.grey[400]!,
                ),
                _buildPodiumBlock(
                  position: 1,
                  name: podiumTeams.isNotEmpty
                      ? podiumTeams[0].teamName
                      : 'N/A',
                  size: 160,
                  color: Colors.amber[600]!,
                ),
                _buildPodiumBlock(
                  position: 3,
                  name: podiumTeams.length > 2
                      ? podiumTeams[2].teamName
                      : 'N/A',
                  size: 100,
                  color: Colors.brown[400]!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (topScorers.isNotEmpty) TopScorerWidget(topScorers: topScorers),
          const SizedBox(height: 32),
          Text(
            'All Teams',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
            ),
          ),
          const SizedBox(height: 8),
          if (groups.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(group.name),
                    children: group.teams.map((team) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          child: ListTile(
                            title: Text(team.teamName),
                            // subtitle: Text('Wins: ${team.wins}'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          if (groups.isEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Text(team.teamName),
                      ),
                    ),
                    // subtitle: Text('Points: ${team.points}'),
                  ),
                );
              },
            ),
        ],
      ),
    );
    // return _buildPodium(teams: podiumTeams);
  }

  Widget _buildPodiumBlock({
    required int position,
    required String name,
    // required double height,
    required Color color,
    required double size,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text(
        //   '#$position',
        //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 6),
        // CircleAvatar(
        //   backgroundColor: Colors.deepOrangeAccent,
        //   child: Text(
        //     name[0].toUpperCase(),
        //     style: const TextStyle(color: Colors.white),
        //   ),
        // ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            // color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Icon(Icons.emoji_events, size: size, color: color),
        // Container(
        //   width: 110,
        //   height: height,
        //   decoration: BoxDecoration(
        //     color: color,
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   alignment: Alignment.topCenter,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 4),
        //     child: Text(
        //       '$position',
        //       style: const TextStyle(
        //         fontSize: 16,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
