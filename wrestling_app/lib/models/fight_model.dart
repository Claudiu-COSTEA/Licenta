class Fight {
  final int fightUUID;
  final int competitionUUID;
  final String fightRound;
  final String fightNumber;
  final String wrestlingStyle;
  final String weightCategory;

  final int wrestlerUUIDRed;
  final String wrestlerNameRed;
  final String coachNameRed;
  final String clubNameRed;
  int pointsRed;

  final int wrestlerUUIDBlue;
  final String wrestlerNameBlue;
  final String coachNameBlue;
  final String clubNameBlue;
  int pointsBlue;

  int? winnerUUID; // Nullable: Set when the match has a winner

  Fight({
    required this.fightUUID,
    required this.competitionUUID,
    required this.fightRound,
    required this.fightNumber,
    required this.wrestlingStyle,
    required this.weightCategory,
    required this.wrestlerUUIDRed,
    required this.wrestlerNameRed,
    required this.coachNameRed,
    required this.clubNameRed,
    this.pointsRed = 0,
    required this.wrestlerUUIDBlue,
    required this.wrestlerNameBlue,
    required this.coachNameBlue,
    required this.clubNameBlue,
    this.pointsBlue = 0,
    this.winnerUUID, // Initially null
  });

  // Factory constructor to create a Fight from JSON
  factory Fight.fromJson(Map<String, dynamic> json) {
    return Fight(
      fightUUID: json['fightUUID'],
      competitionUUID: json['competitionUUID'],
      fightRound: json['fightRound'],
      fightNumber: json['competition_fight_order_number'],
      wrestlingStyle: json['wrestlingStyle'],
      weightCategory: json['weightCategory'],
      wrestlerUUIDRed: json['wrestlerUUIDRed'],
      wrestlerNameRed: json['wrestlerNameRed'],
      coachNameRed: json['coachNameRed'],
      clubNameRed: json['clubNameRed'],
      pointsRed: json['pointsRed'] ?? 0,
      wrestlerUUIDBlue: json['wrestlerUUIDBlue'],
      wrestlerNameBlue: json['wrestlerNameBlue'],
      coachNameBlue: json['coachNameBlue'],
      clubNameBlue: json['clubNameBlue'],
      pointsBlue: json['pointsBlue'] ?? 0,
      winnerUUID: json['winnerUUID'],
    );
  }

  // Convert Fight instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'fightUUID': fightUUID,
      'competitionUUID': competitionUUID,
      'fightRound': fightRound,
      'fightNumber': fightNumber,
      'wrestlingStyle': wrestlingStyle,
      'weightCategory': weightCategory,
      'wrestlerUUIDRed': wrestlerUUIDRed,
      'wrestlerNameRed': wrestlerNameRed,
      'coachNameRed': coachNameRed,
      'clubNameRed': clubNameRed,
      'pointsRed': pointsRed,
      'wrestlerUUIDBlue': wrestlerUUIDBlue,
      'wrestlerNameBlue': wrestlerNameBlue,
      'coachNameBlue': coachNameBlue,
      'clubNameBlue': clubNameBlue,
      'pointsBlue': pointsBlue,
      'winnerUUID': winnerUUID,
    };
  }
}
