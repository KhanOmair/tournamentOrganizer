import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';
import 'package:tourney_app/utils/theme_data.dart';
import 'package:tourney_app/widgets/court_widgets.dart';

class GroupingWidget extends StatefulWidget {
  final List<Team> teams;
  const GroupingWidget({super.key, required this.teams});
  @override
  State<GroupingWidget> createState() => _GroupingWidgetState();
}

class _GroupingWidgetState extends State<GroupingWidget> {
  final _name = TextEditingController();
  final _selected = <String>{};
  final _groups = <Group>[];
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _name.text.trim();
    if (name.isEmpty || _selected.isEmpty) {
      setState(
        () => _error = 'Enter a group name and select at least one team.',
      );
      return;
    }
    if (_groups.any(
      (group) => group.name.toLowerCase() == name.toLowerCase(),
    )) {
      setState(() => _error = 'Choose a different group name.');
      return;
    }
    setState(() {
      _groups.add(
        Group(
          id: 'g${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          teams: widget.teams
              .where((t) => _selected.contains(t.teamId))
              .toList(),
        ),
      );
      _selected.clear();
      _name.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final assigned = _groups
        .expand((g) => g.teams)
        .map((t) => t.teamId)
        .toSet();
    final available = widget.teams
        .where((t) => !assigned.contains(t.teamId))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('CREATE GROUPS')),
      body: SingleChildScrollView(
        child: CourtPage(
          maxWidth: 820,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CourtSectionTitle(
                title: 'Set the groups',
                subtitle: 'Give each group a name and choose its teams.',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Group name',
                          hintText: 'e.g. Group A',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (available.isEmpty)
                        const Text(
                          'All teams have been assigned.',
                          style: TextStyle(color: AppColors.muted),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: available
                              .map(
                                (team) => FilterChip(
                                  label: Text(team.teamName),
                                  selected: _selected.contains(team.teamId),
                                  onSelected: (value) => setState(() {
                                    if (value) {
                                      _selected.add(team.teamId);
                                    } else {
                                      _selected.remove(team.teamId);
                                    }
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: available.isEmpty ? null : _createGroup,
                        icon: const Icon(Icons.add),
                        label: const Text('Add group'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CourtSectionTitle(
                title: 'Your groups',
                trailing: Text(
                  '${_groups.length}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              for (var i = 0; i < _groups.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.grid_view_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(_groups[i].name),
                      subtitle: Text(
                        _groups[i].teams.map((t) => t.teamName).join(' · '),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove group',
                        onPressed: () => setState(() => _groups.removeAt(i)),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _groups.isEmpty
                    ? null
                    : () => Navigator.pop(context, _groups),
                child: const Text('Use these groups'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
