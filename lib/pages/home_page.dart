import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/pages/create_tournament_page.dart';
import 'package:tourney_app/pages/player_details_page.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';
import 'package:tourney_app/widgets/tournament_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _player;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _tournaments;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _player = FirebaseFirestore.instance
        .collection('players')
        .doc(uid)
        .snapshots();
    _tournaments = FirebaseFirestore.instance
        .collection('tournaments')
        .snapshots();
  }

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: _player,
    builder: (context, playerSnapshot) {
      if (playerSnapshot.hasError) {
        return Scaffold(
          body: CourtEmptyState(
            title: 'Couldn’t load your profile',
            message: 'Check your connection and try again.',
            action: TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Back to sign in'),
            ),
          ),
        );
      }
      if (!playerSnapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final data = playerSnapshot.data!.data();
      if (data == null) {
        return Scaffold(
          body: CourtEmptyState(
            title: 'Your profile isn’t ready yet',
            message: 'If you just signed up, your profile will appear shortly.',
            action: TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Back to sign in'),
            ),
          ),
        );
      }
      final player = Player.fromFirestore(data, playerSnapshot.data!.id);
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _tournaments,
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            title: const CourtBrand(),
            actions: [
              IconButton(
                tooltip: 'Your player profile',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerDetailsPage(playerId: player.id),
                  ),
                ),
                icon: CircleAvatar(
                  backgroundColor: AppColors.elevated,
                  foregroundColor: AppColors.primary,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: snapshot.hasError
              ? const CourtEmptyState(
                  title: 'Couldn’t load tournaments',
                  message: 'Check your connection and try again.',
                )
              : !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : TournamentDashboard(
                  player: player,
                  tournaments: snapshot.data!.docs
                      .map(
                        (doc) => Tournament.fromFirestore(doc.data(), doc.id),
                      )
                      .toList(),
                ),
          floatingActionButton: player.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateTournamentPage(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('New tournament'),
                )
              : null,
        ),
      );
    },
  );
}

/// Pure presentation keeps responsive layouts testable without Firebase.
class TournamentDashboard extends StatelessWidget {
  final Player player;
  final List<Tournament> tournaments;
  const TournamentDashboard({
    super.key,
    required this.player,
    required this.tournaments,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: CourtPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME BACK, ${player.name.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text('TOURNAMENTS', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          if (tournaments.isEmpty)
            const CourtEmptyState(
              title: 'The next tournament starts here',
              message:
                  'New tournaments will appear here when your organizer creates them.',
            ),
          for (final entry in {
            'ongoing': 'Ongoing',
            'upcoming': 'Upcoming',
            'completed': 'Completed',
          }.entries)
            if (tournaments.any((t) => t.status.toLowerCase() == entry.key))
              _section(
                context,
                entry.value,
                tournaments
                    .where((t) => t.status.toLowerCase() == entry.key)
                    .toList()
                  ..sort(
                    (a, b) => entry.key == 'completed'
                        ? b.startDate.compareTo(a.startDate)
                        : a.startDate.compareTo(b.startDate),
                  ),
              ),
          const SizedBox(height: 90),
        ],
      ),
    ),
  );

  Widget _section(BuildContext context, String title, List<Tournament> items) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourtSectionTitle(
              title: title,
              trailing: Text(
                '${items.length}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 780 ? 2 : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 18) / columns;
                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: items
                      .map(
                        (t) => SizedBox(
                          width: width,
                          child: TournamentCard(
                            tournament: t,
                            isAdmin: player.isAdmin,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
}
