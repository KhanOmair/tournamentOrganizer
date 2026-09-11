import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tourney_app/models/match.dart';
import 'package:tourney_app/models/round.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/match_crud.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_match_card.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class TournamentRoundsWidget extends StatelessWidget {
  final Tournament tournament;
  final bool isAdmin;
  const TournamentRoundsWidget({
    super.key,
    required this.tournament,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if (tournament.rounds.isEmpty) {
      return const CourtEmptyState(
        title: 'No matches yet',
        message: 'Your organizer can add the first match.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: tournament.rounds.length,
      itemBuilder: (context, index) {
        final round = tournament.rounds[index];
        return CourtPage(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              round.name.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              '${round.matchIds.length} matches',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            childrenPadding: const EdgeInsets.only(top: 12, bottom: 16),
            children: round.matchIds
                .map(
                  (match) => CourtMatchCard(
                    match: match,
                    isAdmin: isAdmin,
                    onTap: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => MatchEditorDialog(
                        tournament: tournament,
                        round: round,
                        match: match,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

typedef PlayerGoalSaver =
    Future<void> Function({
      required String tournamentId,
      required String playerId,
      required int goals,
    });

class MatchEditorDialog extends StatefulWidget {
  final Tournament tournament;
  final Round round;
  final GameMatch match;
  final PlayerGoalSaver savePlayerGoals;
  const MatchEditorDialog({
    super.key,
    required this.tournament,
    required this.round,
    required this.match,
    this.savePlayerGoals = addPlayerGoal,
  });
  @override
  State<MatchEditorDialog> createState() => _MatchEditorDialogState();
}

class _MatchEditorDialogState extends State<MatchEditorDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _homeScore;
  late final TextEditingController _awayScore;
  late final TextEditingController _stream;
  late String _homeId;
  late String _awayId;
  final Map<String, int> _goalsToAdd = {};
  final Map<String, int> _savedGoals = {};
  bool _changeTeams = false;
  bool _saving = false;
  bool _scoreSaved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _homeScore = TextEditingController(text: '${widget.match.scores.team1}');
    _awayScore = TextEditingController(text: '${widget.match.scores.team2}');
    _stream = TextEditingController(text: widget.match.streamUrl);
    _homeId = widget.match.team1.teamId;
    _awayId = widget.match.team2.teamId;
  }

  @override
  void dispose() {
    _homeScore.dispose();
    _awayScore.dispose();
    _stream.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    if (_changeTeams && _homeId == _awayId) {
      setState(() => _error = 'Choose two different teams.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_changeTeams) {
        await updateMatchTeams(
          tournamentId: widget.tournament.id,
          roundId: widget.round.id,
          matchId: widget.match.id,
          newTeam1Id: _homeId,
          newTeam2Id: _awayId,
        );
      } else if (widget.match.winner.isEmpty && !_scoreSaved) {
        await updateMatchScore(
          tournamentId: widget.tournament.id,
          roundId: widget.round.id,
          matchId: widget.match.id,
          team1Score: int.parse(_homeScore.text),
          team2Score: int.parse(_awayScore.text),
        );
        _scoreSaved = true;
      }
      if (_stream.text.trim() != widget.match.streamUrl) {
        await updateMatchStreamUrl(
          tournamentId: widget.tournament.id,
          roundId: widget.round.id,
          matchId: widget.match.id,
          streamUrl: _stream.text.trim(),
        );
      }
      if (!_changeTeams) {
        for (final id in _goalsToAdd.keys.toList()) {
          final goals = _goalsToAdd[id]!;
          if (goals <= 0) continue;
          await widget.savePlayerGoals(
            tournamentId: widget.tournament.id,
            playerId: id,
            goals: goals,
          );
          _savedGoals[id] = (_savedGoals[id] ?? 0) + goals;
          _goalsToAdd[id] = 0;
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'Could not save all changes. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final scorers = widget.tournament.topScorers
        .where((s) => match.playerIds.contains(s.id))
        .toList();
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        scrollable: true,
        title: const Text('EDIT MATCH'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (match.winner.isNotEmpty) ...[
                  const Text(
                    'Result recorded. Scores are locked.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _scoreField(_homeScore, match.team1.teamName),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 42, 12, 0),
                      child: Text(
                        ':',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                    Expanded(
                      child: _scoreField(_awayScore, match.team2.teamName),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Change teams'),
                  value: _changeTeams,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _changeTeams = value),
                ),
                if (_changeTeams) ...[
                  const SizedBox(height: 12),
                  _teamPicker(
                    'Home team',
                    _homeId,
                    (value) => setState(() => _homeId = value!),
                  ),
                  const SizedBox(height: 16),
                  _teamPicker(
                    'Away team',
                    _awayId,
                    (value) => setState(() => _awayId = value!),
                  ),
                ],
                if (!_changeTeams &&
                    widget.tournament.sport == 'fifa' &&
                    !match.playerIds.contains('BYE') &&
                    scorers.isNotEmpty) ...[
                  const Divider(height: 36),
                  Text(
                    'ADD PLAYER GOALS',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose how many goals to add. They are added to the tournament total when you save.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  for (final scorer in scorers)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(scorer.name),
                                Text(
                                  'Total: ${scorer.goals + (_savedGoals[scorer.id] ?? 0)}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Decrease goals to add for ${scorer.name}',
                            onPressed:
                                _saving || (_goalsToAdd[scorer.id] ?? 0) <= 0
                                ? null
                                : () => setState(
                                    () => _goalsToAdd[scorer.id] =
                                        _goalsToAdd[scorer.id]! - 1,
                                  ),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Semantics(
                            label: 'Goals to add for ${scorer.name}',
                            value: '${_goalsToAdd[scorer.id] ?? 0}',
                            child: Text(
                              '${_goalsToAdd[scorer.id] ?? 0}',
                              key: ValueKey('goals-to-add-${scorer.id}'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Increase goals to add for ${scorer.name}',
                            onPressed: _saving
                                ? null
                                : () => setState(
                                    () => _goalsToAdd.update(
                                      scorer.id,
                                      (v) => v + 1,
                                      ifAbsent: () => 1,
                                    ),
                                  ),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _stream,
                  enabled: !_saving,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Stream link (optional)',
                    hintText: 'https://',
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final uri = Uri.tryParse(value.trim());
                    return uri != null &&
                            ['http', 'https'].contains(uri.scheme) &&
                            uri.host.isNotEmpty
                        ? null
                        : 'Enter a valid https:// or http:// link';
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
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
            child: Text(_saving ? 'Saving…' : 'Save changes'),
          ),
        ],
      ),
    );
  }

  Widget _scoreField(TextEditingController controller, String team) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(team, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        enabled:
            !_saving &&
            !_changeTeams &&
            widget.match.winner.isEmpty &&
            !_scoreSaved,
        textAlign: TextAlign.center,
        style: courtHeading(36, color: AppColors.primary),
        decoration: const InputDecoration(labelText: 'Score'),
        validator: (value) =>
            !_changeTeams && (value == null || int.tryParse(value) == null)
            ? 'Enter a score'
            : null,
      ),
    ],
  );

  Widget _teamPicker(
    String label,
    String selectedId,
    ValueChanged<String?> onChanged,
  ) {
    final options = <String, Team>{
      widget.match.team1.teamId: widget.match.team1,
      widget.match.team2.teamId: widget.match.team2,
      for (final team in widget.tournament.teams) team.teamId: team,
    };
    return DropdownButtonFormField<String>(
      value: selectedId,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options.values
          .map(
            (team) => DropdownMenuItem(
              value: team.teamId,
              child: Text(team.teamName, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _saving ? null : onChanged,
    );
  }
}
