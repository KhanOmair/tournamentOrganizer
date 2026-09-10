import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class StandingsTable extends StatelessWidget {
  final List<Team> teams;
  final List<Group> groups;
  const StandingsTable({super.key, required this.teams, required this.groups});

  List<Team> _sortTeams(List<Team> values) =>
      List<Team>.from(values)..sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        if (b.wins != a.wins) return b.wins.compareTo(a.wins);
        return a.teamName.compareTo(b.teamName);
      });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) {
      return const CourtEmptyState(
        title: 'No standings yet',
        message: 'Teams will appear here when they are added.',
      );
    }
    final currentTeams = {for (final team in teams) team.teamId: team};
    return SingleChildScrollView(
      child: CourtPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groups.isEmpty)
              _table(context, _sortTeams(teams))
            else
              for (final group in groups) ...[
                CourtSectionTitle(title: group.name),
                _table(
                  context,
                  _sortTeams(
                    group.teams
                        .map((t) => currentTeams[t.teamId] ?? t)
                        .toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            const SizedBox(height: 16),
            const Text(
              'P  Played    W  Wins    D  Draws    L  Losses\nGD  Goal difference    GF  Goals for    GA  Goals against',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(BuildContext context, List<Team> sorted) => Card(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Team')),
              DataColumn(label: Text('P'), numeric: true),
              DataColumn(label: Text('W'), numeric: true),
              DataColumn(label: Text('D'), numeric: true),
              DataColumn(label: Text('L'), numeric: true),
              DataColumn(label: Text('Pts'), numeric: true),
              DataColumn(label: Text('GD'), numeric: true),
              DataColumn(label: Text('GF'), numeric: true),
              DataColumn(label: Text('GA'), numeric: true),
            ],
            rows: List.generate(sorted.length, (i) {
              final t = sorted[i];
              return DataRow(
                color: WidgetStatePropertyAll(
                  i == 0
                      ? AppColors.primary.withValues(alpha: .05)
                      : Colors.transparent,
                ),
                cells: [
                  DataCell(
                    Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: i == 0 ? AppColors.primary : AppColors.muted,
                      ),
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        t.teamName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(Text('${t.played}')),
                  DataCell(Text('${t.wins}')),
                  DataCell(Text('${t.draws}')),
                  DataCell(Text('${t.losses}')),
                  DataCell(
                    Text(
                      '${t.points}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DataCell(Text('${t.goalDifference}')),
                  DataCell(Text('${t.goalsFor}')),
                  DataCell(Text('${t.goalsAgainst}')),
                ],
              );
            }),
          ),
        ),
      ),
    ),
  );
}
