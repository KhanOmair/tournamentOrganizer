import 'package:flutter/material.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class TopScorerWidget extends StatelessWidget {
  final List<TopScorer> topScorers;
  const TopScorerWidget({super.key, required this.topScorers});

  @override
  Widget build(BuildContext context) {
    final sorted = [...topScorers]..sort((a, b) => b.goals.compareTo(a.goals));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CourtSectionTitle(title: 'Top scorers'),
        if (sorted.isEmpty)
          const CourtEmptyState(title: 'No goals recorded yet')
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.elevated,
                      foregroundColor: AppColors.primary,
                      child: Text('${i + 1}'),
                    ),
                    title: Text(sorted[i].name),
                    trailing: Text(
                      '${sorted[i].goals} goals',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
