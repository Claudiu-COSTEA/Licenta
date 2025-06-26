class CompetitionFight {
  final int competitionUUID;                // Nou
  final int competitionFightUUID;
  final int competitionFightOrderNumber;
  final String competitionRound;
  final String wrestlingStyle;
  final String competitionFightWeightCategory;
  final int refereeUUID1, refereeUUID2, refereeUUID3;
  final int wrestlingClubUUIDRed, wrestlingClubUUIDBlue;
  final int coachUUIDRed, coachUUIDBlue;
  final int wrestlerUUIDRed, wrestlerUUIDBlue;
  final int wrestlerPointsRed, wrestlerPointsBlue;

  // Câmpuri opționale pentru nume
  String? wrestlerNameRed, coachNameRed, clubNameRed;
  String? wrestlerNameBlue, coachNameBlue, clubNameBlue;

  CompetitionFight({
    required this.competitionUUID,                // Nou
    required this.competitionFightUUID,
    required this.competitionFightOrderNumber,
    required this.competitionRound,
    required this.wrestlingStyle,
    required this.competitionFightWeightCategory,
    required this.refereeUUID1,
    required this.refereeUUID2,
    required this.refereeUUID3,
    required this.wrestlingClubUUIDRed,
    required this.wrestlingClubUUIDBlue,
    required this.coachUUIDRed,
    required this.coachUUIDBlue,
    required this.wrestlerUUIDRed,
    required this.wrestlerUUIDBlue,
    required this.wrestlerPointsRed,
    required this.wrestlerPointsBlue,
    this.wrestlerNameRed,
    this.coachNameRed,
    this.clubNameRed,
    this.wrestlerNameBlue,
    this.coachNameBlue,
    this.clubNameBlue,
  });

  factory CompetitionFight.fromJson(Map<String, dynamic> json) {
    return CompetitionFight(
      competitionUUID: json['competition_UUID'] as int,               // Nou
      competitionFightUUID: json['competition_fight_UUID'] as int,
      competitionFightOrderNumber: json['competition_fight_order_number'] as int,
      competitionRound: json['competition_round'] as String,
      wrestlingStyle: json['wrestling_style'] as String,
      competitionFightWeightCategory: json['competition_fight_weight_category'] as String,
      refereeUUID1: json['referee_UUID_1'] as int,
      refereeUUID2: json['referee_UUID_2'] as int,
      refereeUUID3: json['referee_UUID_3'] as int,
      wrestlingClubUUIDRed: json['wrestling_club_UUID_red'] as int,
      wrestlingClubUUIDBlue: json['wrestling_club_UUID_blue'] as int,
      coachUUIDRed: json['coach_UUID_red'] as int,
      coachUUIDBlue: json['coach_UUID_blue'] as int,
      wrestlerUUIDRed: json['wrestler_UUID_red'] as int,
      wrestlerUUIDBlue: json['wrestler_UUID_blue'] as int,
      wrestlerPointsRed: json['wrestler_points_red'] as int,
      wrestlerPointsBlue: json['wrestler_points_blue'] as int,
    );
  }
}
