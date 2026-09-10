import 'package:flutter/material.dart';
import 'package:tourney_app/models/match.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class CourtMatchCard extends StatelessWidget {
  final GameMatch match;
  final bool isAdmin;
  final VoidCallback? onTap;
  const CourtMatchCard({
    super.key,
    required this.match,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: InkWell(
        onTap: isAdmin ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CourtStatus(status: match.status),
                  const Spacer(),
                  if (isAdmin)
                    IconButton(
                      tooltip: 'Edit match',
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      match.team1.teamName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Semantics(
                      label:
                          'Score ${match.scores.team1} to ${match.scores.team2}',
                      child: Text(
                        '${match.scores.team1} : ${match.scores.team2}',
                        style: courtHeading(40, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.team2.teamName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (match.streamUrl.trim().isNotEmpty) ...[
                const Divider(height: 24),
                TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(match.streamUrl);
                    if (uri == null ||
                        !['http', 'https'].contains(uri.scheme)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This stream link is not valid.'),
                        ),
                      );
                      return;
                    }
                    try {
                      final opened = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!opened && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open the stream.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open the stream.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Watch stream'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
