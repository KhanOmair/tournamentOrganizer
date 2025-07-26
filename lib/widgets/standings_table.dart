import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';

class StandingsTable extends StatelessWidget {
  final List<Team> teams;

  const StandingsTable({Key? key, required this.teams}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final sortedTeams = _sortTeams(teams);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // add a border to the table
        border: TableBorder.all(color: Colors.black, width: 1),
        columns: const [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Team')),
          DataColumn(label: Text('P')),
          DataColumn(label: Text('W')),
          DataColumn(label: Text('D')),
          DataColumn(label: Text('L')),
          DataColumn(label: Text('GD')),
          DataColumn(label: Text('Pts')),
        ],
        rows: List.generate(sortedTeams.length, (index) {
          final team = sortedTeams[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')), // Rank
              DataCell(
                Row(
                  children: [
                    //   CircleAvatar(
                    //     radius: 12,
                    //     backgroundColor: Colors.deepOrangeAccent,
                    //     child: Text(
                    //       team.teamName[0].toUpperCase(),
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(width: 2),
                    // make the team name bold and multiline if too long
                    Expanded(
                      child: Text(
                        team.teamName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text('${team.played}')),
              DataCell(Text('${team.wins}')),
              DataCell(Text('${team.draws}')),
              DataCell(Text('${team.losses}')),
              DataCell(Text('${team.goalDifference}')),
              DataCell(Text('${team.points}')),
            ],
          );
        }),
      ),
    );
  }
}
