import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/models/team.dart';

class CreateTeamsPage extends StatefulWidget {
  // final List<Player> allPlayers;

  const CreateTeamsPage({Key? key}) : super(key: key);

  @override
  _CreateTeamsPageState createState() => _CreateTeamsPageState();
}

class _CreateTeamsPageState extends State<CreateTeamsPage> {
  List<Player> selectedPlayers = [];
  List<Team> customTeams = [];
  List<Player> allPlayers = [];

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('players')
        .get();
    final players = snapshot.docs
        .map((doc) => Player.fromFirestore(doc.data(), doc.id))
        .toList();
    setState(() {
      allPlayers = players;
    });
  }

  void _addTeam() {
    if (selectedPlayers.length == 2) {
      setState(() {
        customTeams.add(
          Team(
            teamId: DateTime.now().millisecondsSinceEpoch.toString(),
            teamName: "${selectedPlayers[0].name} & ${selectedPlayers[1].name}",
            playerIdsTeam: [selectedPlayers[0].id, selectedPlayers[1].id],
            played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            goalsFor: 0,
            goalsAgainst: 0,
          ),
        );
        selectedPlayers.clear();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select exactly 2 players')));
    }
  }

  void _generateTournament() {
    if (customTeams.isEmpty || customTeams.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create at least two teams first')),
      );
      return;
    }

    // TODO: Navigate to Tournament Page with created teams
    Navigator.pop(context, customTeams);
  }

  @override
  Widget build(BuildContext context) {
    final availablePlayers = allPlayers.where((p) {
      return !customTeams.any((t) => t.playerIdsTeam.contains(p.id));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Teams'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select 2 players to form a team:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Available Players
            Expanded(
              child: ListView.builder(
                itemCount: availablePlayers.length,
                itemBuilder: (context, index) {
                  final player = availablePlayers[index];
                  final isSelected = selectedPlayers.contains(player);
                  return ListTile(
                    title: Text(player.name),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedPlayers.remove(player);
                        } else if (selectedPlayers.length < 2) {
                          selectedPlayers.add(player);
                        }
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _addTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
              child: const Text('Add Team'),
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text(
              'Created Teams:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Created Teams List
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: customTeams.length,
                itemBuilder: (context, index) {
                  final team = customTeams[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(team.teamName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => customTeams.removeAt(index));
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _generateTournament,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
