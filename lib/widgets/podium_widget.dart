import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';
import 'package:tourney_app/widgets/top_scorer.dart';

class PodiumWidget extends StatelessWidget {
  final List<Team> teams;
  final List<Group> groups;
  final List<TopScorer> topScorers;
  const PodiumWidget({
    super.key,
    required this.teams,
    required this.groups,
    required this.topScorers,
  });

  List<Team> get podiumTeams {
    final sorted = List<Team>.from(teams)
      ..sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        if (b.wins != a.wins) return b.wins.compareTo(a.wins);
        return a.teamName.compareTo(b.teamName);
      });
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const CourtEmptyState(title: 'No teams yet');
    final leaders = podiumTeams;
    return SingleChildScrollView(
      child: CourtPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CourtSectionTitle(title: 'Leading teams'),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 500;
                final blocks = List.generate(
                  leaders.length,
                  (i) => _leader(context, leaders[i], i),
                );
                return stacked
                    ? Column(
                        children: blocks
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: b,
                              ),
                            )
                            .toList(),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < blocks.length; i++) ...[
                            if (i > 0) const SizedBox(width: 14),
                            Expanded(child: blocks[i]),
                          ],
                        ],
                      );
              },
            ),
            const SizedBox(height: 32),
            if (topScorers.isNotEmpty) ...[
              TopScorerWidget(topScorers: topScorers),
              const SizedBox(height: 32),
            ],
            const CourtSectionTitle(title: 'All teams'),
            if (groups.isNotEmpty)
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(group.name),
                      children: group.teams
                          .map(
                            (team) => ListTile(
                              leading: const Icon(Icons.groups_outlined),
                              title: Text(team.teamName),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
            else
              for (final team in teams)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.groups_outlined),
                      title: Text(team.teamName),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _leader(BuildContext context, Team team, int index) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 24,
                color: index == 0 ? AppColors.primary : AppColors.muted,
              ),
              const Spacer(),
              Text(
                '0${index + 1}',
                style: courtHeading(
                  32,
                  color: index == 0 ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            team.teamName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '${team.points} points · ${team.wins} wins',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
