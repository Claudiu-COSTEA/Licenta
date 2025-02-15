class Coach {
  final String coachUUID;
  final String wrestlingClubUUID;

  Coach({
    required this.coachUUID,
    required this.wrestlingClubUUID,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      coachUUID: json['coach_UUID'],
      wrestlingClubUUID: json['wrestling_club_UUID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coach_UUID': coachUUID,
      'wrestling_club_UUID': wrestlingClubUUID,
    };
  }
}
