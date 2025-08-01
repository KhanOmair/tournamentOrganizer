import 'package:flutter/material.dart';
import 'package:tourney_app/models/team.dart';
import 'package:tourney_app/models/tournament.dart';

class GroupingWidget extends StatefulWidget {
  final List<Team> teams;

  const GroupingWidget({Key? key, required this.teams}) : super(key: key);

  @override
  State<GroupingWidget> createState() => _GroupingWidgetState();
}

class _GroupingWidgetState extends State<GroupingWidget> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedTeam = [];
  final List<Group> _groups = [];

  void _createGroup() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || _selectedTeam.isEmpty) return;

    final selectedTeams = widget.teams
        .where((team) => _selectedTeam.contains(team.teamId))
        .toList();

    setState(() {
      _groups.add(
        Group(
          id: 'g${DateTime.now().millisecondsSinceEpoch}',
          name: groupName,
          teams: selectedTeams,
        ),
      );
      _selectedTeam.clear();
      _groupNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create Group", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Select Teams",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: widget.teams.map((team) {
                final isSelected = _selectedTeam.contains(team.teamId);
                return FilterChip(
                  label: Text(team.teamName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTeam.add(team.teamId);
                      } else {
                        _selectedTeam.remove(team.teamId);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _createGroup,
                child: const Text("Add Group"),
              ),
            ),
            const Divider(height: 40),
            Text(
              "Created Groups",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ..._groups.map((group) {
              return Card(
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Text(
                    group.teams.map((team) => team.teamName).join(', '),
                  ),
                ),
              );
            }).toList(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _groups);
              },
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}
