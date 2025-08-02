import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';

class StandingsTable extends StatelessWidget {
  final List<Team> teams;
  final List<Group> groups;

  const StandingsTable({Key? key, required this.teams, required this.groups})
    : super(key: key);

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
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: groups.isEmpty
            ? showStandingsTable(sortedTeams)
            : showGroupTable(),
      ),
    );
  }

  Widget showGroupTable() {
    final teamMap = {for (var t in teams) t.teamId: t};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((group) {
          final updatedGroupTeams = group.teams
              .map((t) => teamMap[t.teamId] ?? t)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              showStandingsTable(_sortTeams(updatedGroupTeams)),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget showStandingsTable(sortedTeams) {
    return DataTable(
      // add a border to the table
      border: TableBorder.all(color: Colors.black, width: 1),
      columns: const [
        DataColumn(label: Text('Rank')),
        DataColumn(label: Text('Team')),
        DataColumn(label: Text('P')),
        DataColumn(label: Text('W')),
        DataColumn(label: Text('D')),
        DataColumn(label: Text('L')),
        DataColumn(label: Text('Pts')),
        DataColumn(label: Text('GD')),
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
            DataCell(Text('${team.points}')),
            DataCell(Text('${team.goalDifference}')),
          ],
        );
      }),
    );
  }
}
