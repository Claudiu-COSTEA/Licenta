class WrestlerVerification {
  final int wrestlerUUID;
  final String wrestlerName;
  final String wrestlingStyle;
  final int weightCategory;
  final int coachUUID;
  final String coachName;
  final int wrestlingClubUUID;
  final String wrestlingClubName;
  final int competitionUUID;
  final String competitionName;

  WrestlerVerification({
    required this.wrestlerUUID,
    required this.wrestlerName,
    required this.wrestlingStyle,
    required this.weightCategory,
    required this.coachUUID,
    required this.coachName,
    required this.wrestlingClubUUID,
    required this.wrestlingClubName,
    required this.competitionUUID,
    required this.competitionName,
  });

  // Factory method to create a WrestlerVerification object from JSON
  factory WrestlerVerification.fromJson(Map<String, dynamic> json) {
    return WrestlerVerification(
      wrestlerUUID: json['wrestler_UUID'],
      wrestlerName: json['wrestler_name'],
      wrestlingStyle: json['wrestling_style'],
      weightCategory: int.tryParse(json['weight_category'].toString()) ?? 0,
      coachUUID: json['coach_UUID'],
      coachName: json['coach_name'],
      wrestlingClubUUID: json['wrestling_club_UUID'],
      wrestlingClubName: json['wrestling_club_name'],
      competitionUUID: json['competition_UUID'],
      competitionName: json['competition_name'],
    );
  }
}
