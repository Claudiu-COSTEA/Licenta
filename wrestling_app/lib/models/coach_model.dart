class Coach {
  final int coachUUID;
  final int wrestlingClubUUID;
  final String wrestlingStyle;

  Coach({
    required this.coachUUID,
    required this.wrestlingClubUUID,
    required this.wrestlingStyle,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      coachUUID: json['coach_UUID'],
      wrestlingClubUUID: json['wrestling_club_UUID'],
      wrestlingStyle: json['wrestling_style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coach_UUID': coachUUID,
      'wrestling_club_UUID': wrestlingClubUUID,
      'wrestling_style': wrestlingStyle,
    };
  }
}
