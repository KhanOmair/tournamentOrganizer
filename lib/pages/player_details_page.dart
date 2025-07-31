import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourney_app/models/player.dart';
import 'package:tourney_app/pages/login_page.dart';

class PlayerDetailsPage extends StatefulWidget {
  final String playerId;

  const PlayerDetailsPage({super.key, required this.playerId});

  @override
  State<PlayerDetailsPage> createState() => _PlayerDetailsPageState();
}

class _PlayerDetailsPageState extends State<PlayerDetailsPage> {
  Player? player;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlayerData();
  }

  Future<void> fetchPlayerData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('players')
          .doc(widget.playerId)
          .get();

      if (doc.exists) {
        setState(() {
          player = Player.fromFirestore(doc.data()!, doc.id);
          isLoading = false;
        });
      } else {
        throw Exception("Player not found");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load player: $e')));
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate to login screen and remove all previous routes
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Replace the first page with the LoginPage
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : player == null
          ? const Center(child: Text('Player not found'))
          : Stack(
              children: [
                // Background Gradient
                Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFE6B8B), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Top Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // logout button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => logout(context),
                  ),
                ),

                // Profile Card
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Hero(
                              tag: player!.id,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.orange.shade100,
                                child: Text(
                                  player!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              player!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              player!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Chip(
                            //   label: Text(
                            //     "Rating: ${player!.rating.toStringAsFixed(1)}",
                            //     style: const TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            //   backgroundColor: Colors.deepOrange,
                            // ),
                            const SizedBox(height: 20),
                            const Divider(),

                            // Stats Section
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatTile(
                                    Icons.sports_esports,
                                    "Matches",
                                    player!.globalStats.matchesPlayed,
                                  ),
                                  _buildDivider(),
                                  _buildStatTile(
                                    Icons.emoji_events,
                                    "Wins",
                                    player!.globalStats.wins,
                                  ),
                                  _buildDivider(),
                                  _buildStatTile(
                                    Icons.cancel_outlined,
                                    "Losses",
                                    player!.globalStats.losses,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStatTile(
                              Icons.tour,
                              "Tournaments",
                              player!.globalStats.tournamentsPlayed,
                            ),
                            const SizedBox(height: 20),
                            if (player!.isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Admin",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 28),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return const VerticalDivider(
      color: Colors.grey,
      thickness: 1,
      width: 30,
      indent: 8,
      endIndent: 8,
    );
  }
}
