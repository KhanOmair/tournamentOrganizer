import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class PlayerDetailsPage extends StatefulWidget {
  final String playerId;
  const PlayerDetailsPage({super.key, required this.playerId});
  @override
  State<PlayerDetailsPage> createState() => _PlayerDetailsPageState();
}

class _PlayerDetailsPageState extends State<PlayerDetailsPage> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _profile;
  @override
  void initState() {
    super.initState();
    _profile = FirebaseFirestore.instance
        .collection('players')
        .doc(widget.playerId)
        .get();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not sign out. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('PLAYER PROFILE'),
      actions: [
        IconButton(
          tooltip: 'Sign out',
          onPressed: _logout,
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CourtEmptyState(
            title: 'Couldn’t load your profile',
            message: 'Check your connection and try again.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data();
        if (data == null) {
          return const CourtEmptyState(title: 'Player not found');
        }
        return PlayerProfileView(
          player: Player.fromFirestore(data, snapshot.data!.id),
        );
      },
    ),
  );
}

class PlayerProfileView extends StatelessWidget {
  final Player player;
  const PlayerProfileView({super.key, required this.player});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: CourtPage(
      maxWidth: 860,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                        style: courtHeading(44, color: AppColors.background),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      player.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      player.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    if (player.isAdmin) ...[
                      const SizedBox(height: 20),
                      const CourtStatus(status: 'Admin'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          const CourtSectionTitle(title: 'Your record'),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 4 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              final stats = [
                (
                  Icons.sports_esports_outlined,
                  'Matches',
                  player.globalStats.matchesPlayed,
                ),
                (Icons.emoji_events_outlined, 'Wins', player.globalStats.wins),
                (Icons.flag_outlined, 'Losses', player.globalStats.losses),
                (
                  Icons.grid_view_outlined,
                  'Tournaments',
                  player.globalStats.tournamentsPlayed,
                ),
              ];
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: stats
                    .map(
                      (stat) => SizedBox(
                        width: width,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(stat.$1, color: AppColors.muted, size: 22),
                                const SizedBox(height: 20),
                                Text(
                                  '${stat.$3}',
                                  style: courtHeading(
                                    42,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stat.$2,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    ),
  );
}
