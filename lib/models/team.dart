class Team {
  final String teamId;
  final String teamName;
  final List<String> playerIdsTeam;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  Team({
    required this.teamId,
    required this.teamName,
    required this.playerIdsTeam,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get points => (wins * 3) + draws;
  int get goalDifference => goalsFor - goalsAgainst;

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      teamId: map['teamId'] ?? '',
      teamName: map['team'] ?? 'Unknown',
      playerIdsTeam: List<String>.from(map['playerIdsTeam'] ?? []),
      played: map['played'] ?? 0,
      wins: map['wins'] ?? 0,
      draws: map['draws'] ?? 0,
      losses: map['losses'] ?? 0,
      goalsFor: map['goalsFor'] ?? 0,
      goalsAgainst: map['goalsAgainst'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'team': teamName,
      'playerIdsTeam': playerIdsTeam,
      'played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
    };
  }
}
