import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/match_crud.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';
import 'package:tourney_app/widgets/podium_widget.dart';
import 'package:tourney_app/widgets/tourney_rounds_widget.dart';
import 'package:tourney_app/widgets/standings_table.dart';

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;
  final bool isAdmin;
  const TournamentDetailPage({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });
  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _tournament;
  @override
  void initState() {
    super.initState();
    _tournament = FirebaseFirestore.instance
        .collection('tournaments')
        .doc(widget.tournament.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _tournament,
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final tournament = data == null
              ? widget.tournament
              : Tournament.fromFirestore(data, snapshot.data!.id);
          return Scaffold(
            appBar: AppBar(
              title: const Text('TOURNAMENT'),
              actions: [
                if (widget.isAdmin &&
                    !snapshot.hasError &&
                    (!snapshot.hasData || snapshot.data!.exists))
                  IconButton(
                    tooltip: 'Add match',
                    icon: const Icon(Icons.add),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => _AddMatchDialog(tournament: tournament),
                    ),
                  ),
                const SizedBox(width: 12),
              ],
            ),
            body: snapshot.hasError
                ? const CourtEmptyState(
                    title: 'Couldn’t load this tournament',
                    message: 'Check your connection and try again.',
                  )
                : snapshot.hasData && !snapshot.data!.exists
                ? const CourtEmptyState(title: 'Tournament no longer available')
                : TournamentDetailBody(
                    tournament: tournament,
                    isAdmin: widget.isAdmin,
                  ),
          );
        },
      );
}

class TournamentDetailBody extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;
  const TournamentDetailBody({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    initialIndex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CourtPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CourtStatus(status: tournament.status),
                  Text(
                    '${tournament.sport.toUpperCase()} · ${tournament.type}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                tournament.name.toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        const TabBar(
          tabs: [
            Tab(text: 'Standings'),
            Tab(text: 'Matches'),
            Tab(text: 'Teams'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              StandingsTable(
                teams: tournament.teams,
                groups: tournament.groups,
              ),
              TournamentRoundsWidget(tournament: tournament, isAdmin: isAdmin),
              PodiumWidget(
                teams: tournament.teams,
                groups: tournament.groups,
                topScorers: tournament.topScorers,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AddMatchDialog extends StatefulWidget {
  final Tournament tournament;
  const _AddMatchDialog({required this.tournament});
  @override
  State<_AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<_AddMatchDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Team? _home;
  Team? _away;
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await createMatch(
        tournamentId: widget.tournament.id,
        homeTeam: _home,
        awayTeam: _away,
        roundName: _name.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create the match. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('ADD A MATCH'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Round name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a round name'
                  : null,
            ),
            const SizedBox(height: 20),
            _teamPicker(
              'Home team',
              _home,
              (value) => setState(() => _home = value),
            ),
            const SizedBox(height: 20),
            _teamPicker(
              'Away team',
              _away,
              (value) => setState(() => _away = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Creating…' : 'Create match'),
      ),
    ],
  );

  Widget _teamPicker(
    String label,
    Team? value,
    ValueChanged<Team?> onChanged,
  ) => DropdownButtonFormField<Team>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: widget.tournament.teams
        .map(
          (t) => DropdownMenuItem(
            value: t,
            child: Text(t.teamName, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: _saving ? null : onChanged,
    validator: (value) => value == null
        ? 'Select a team'
        : _home != null && _home == _away
        ? 'Choose two different teams'
        : null,
  );
}
