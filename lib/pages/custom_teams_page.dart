import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class CreateTeamsPage extends StatefulWidget {
  final List<String> selectedPlayers;
  const CreateTeamsPage({super.key, required this.selectedPlayers});
  @override
  State<CreateTeamsPage> createState() => _CreateTeamsPageState();
}

class _CreateTeamsPageState extends State<CreateTeamsPage> {
  final List<Player> _selected = [];
  final List<Team> _teams = [];
  List<Player> _players = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('players')
          .get();
      if (!mounted) return;
      setState(() {
        _players = snapshot.docs
            .where((doc) => widget.selectedPlayers.contains(doc.id))
            .map((doc) => Player.fromFirestore(doc.data(), doc.id))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load players.';
        });
      }
    }
  }

  void _addTeam() {
    if (_selected.length != 2) return;
    setState(() {
      _teams.add(
        Team(
          teamId: DateTime.now().microsecondsSinceEpoch.toString(),
          teamName: '${_selected[0].name} & ${_selected[1].name}',
          playerIdsTeam: _selected.map((p) => p.id).toList(),
        ),
      );
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = _players
        .where((p) => !_teams.any((t) => t.playerIdsTeam.contains(p.id)))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('CUSTOM TEAMS')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? CourtEmptyState(
              title: _error!,
              action: OutlinedButton(
                onPressed: _fetchPlayers,
                child: const Text('Try again'),
              ),
            )
          : SingleChildScrollView(
              child: CourtPage(
                maxWidth: 820,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CourtSectionTitle(
                      title: 'Pick your pair',
                      subtitle: 'Select two players for each team.',
                      trailing: Text(
                        '${_selected.length}/2',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    if (available.isEmpty)
                      const CourtEmptyState(
                        title: 'Everyone has a team',
                        icon: Icons.check_circle_outline,
                      )
                    else
                      Card(
                        child: Column(
                          children: available.map((player) {
                            final selected = _selected.contains(player);
                            return CheckboxListTile(
                              value: selected,
                              secondary: CircleAvatar(
                                backgroundColor: AppColors.elevated,
                                foregroundColor: AppColors.primary,
                                child: Text(
                                  player.name.isEmpty
                                      ? '?'
                                      : player.name[0].toUpperCase(),
                                ),
                              ),
                              title: Text(player.name),
                              onChanged: !selected && _selected.length == 2
                                  ? null
                                  : (value) => setState(() {
                                      if (value == true) {
                                        _selected.add(player);
                                      } else {
                                        _selected.remove(player);
                                      }
                                    }),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _selected.length == 2 ? _addTeam : null,
                      icon: const Icon(Icons.group_add_outlined),
                      label: const Text('Add team'),
                    ),
                    const SizedBox(height: 36),
                    CourtSectionTitle(
                      title: 'Your teams',
                      trailing: Text(
                        '${_teams.length}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ),
                    for (var i = 0; i < _teams.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            leading: Text(
                              '${i + 1}'.padLeft(2, '0'),
                              style: courtHeading(24, color: AppColors.muted),
                            ),
                            title: Text(_teams[i].teamName),
                            trailing: IconButton(
                              tooltip: 'Remove team',
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  setState(() => _teams.removeAt(i)),
                            ),
                          ),
                        ),
                      ),
                    if (_teams.isEmpty)
                      const Text(
                        'Created teams will appear here.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _teams.length < 2
                          ? null
                          : () => Navigator.pop(context, _teams),
                      child: const Text('Use these teams'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create at least two teams to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
