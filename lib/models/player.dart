class Player {
  final String id;
  final String name;
  final String fname;
  final String lname;
  final String email; // Optional, if you want to store email
  final double rating;
  bool isAdmin = false;
  final PlayerGlobalStats globalStats;

  Player({
    required this.email,
    required this.id,
    required this.name,
    required this.fname,
    required this.lname,
    required this.rating,
    required this.globalStats,
    required this.isAdmin,
  });

  factory Player.fromFirestore(Map<String, dynamic> data, String docId) {
    return Player(
      email: data['email'] ?? '',
      id: docId,
      name: data['name'] ?? '',
      fname: data['fname'] ?? '',
      lname: data['lname'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      globalStats: PlayerGlobalStats.fromMap(
        data['globalStats'] ?? <String, dynamic>{},
      ),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'fname': fname,
      'lname': lname, 
      'rating': rating,
      'globalStats': globalStats.toMap(),
      'isAdmin': isAdmin,
    };
  }
}

class PlayerGlobalStats {
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int tournamentsPlayed;

  PlayerGlobalStats({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.tournamentsPlayed,
  });

  factory PlayerGlobalStats.fromMap(Map<String, dynamic> map) {
    return PlayerGlobalStats(
      matchesPlayed: map['matchesPlayed'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      tournamentsPlayed: map['tournamentsPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'losses': losses,
      'tournamentsPlayed': tournamentsPlayed,
    };
  }
}
