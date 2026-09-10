import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/tournament_detail_page.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/utils/tournament_crud.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });

  int get matchesLeft => tournament.rounds
      .expand((r) => r.matchIds)
      .where((m) => m.status != 'completed')
      .length;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete tournament?'),
        content: Text('“${tournament.name}” and its matches will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep tournament'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await deleteTournament(tournament.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the tournament.')),
        );
      }
    }
  }

  Future<void> _start(BuildContext context) async {
    try {
      await updatetTournamentStatus(
        tournamentId: tournament.id,
        status: 'ongoing',
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start the tournament.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = tournament.status.toLowerCase() == 'upcoming';
    final completed = tournament.status.toLowerCase() == 'completed';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CourtStatus(status: tournament.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tournament.sport.toUpperCase(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton<String>(
                    tooltip: 'Tournament actions',
                    onSelected: (action) =>
                        action == 'delete' ? _delete(context) : _start(context),
                    itemBuilder: (_) => [
                      if (upcoming)
                        const PopupMenuItem(
                          value: 'start',
                          child: Text('Start tournament'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete tournament',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              tournament.name.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              tournament.type,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _detail(
                  Icons.calendar_today_outlined,
                  DateFormat('d MMM yyyy').format(tournament.startDate),
                ),
                _detail(
                  Icons.people_outline,
                  '${tournament.playerIds.length} players',
                ),
                _detail(
                  completed
                      ? Icons.check_circle_outline
                      : Icons.sports_esports_outlined,
                  completed ? 'Completed' : '$matchesLeft matches left',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: upcoming && isAdmin
                  ? FilledButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Start tournament'),
                      onPressed: () => _start(context),
                    )
                  : FilledButton.icon(
                      onPressed: upcoming
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TournamentDetailPage(
                                  tournament: tournament,
                                  isAdmin: isAdmin,
                                ),
                              ),
                            ),
                      icon: Icon(
                        upcoming ? Icons.schedule : Icons.arrow_outward,
                        size: 18,
                      ),
                      label: Text(
                        upcoming
                            ? 'Starts ${DateFormat('d MMM').format(tournament.startDate)}'
                            : 'View tournament',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.muted),
      const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    ],
  );
}
