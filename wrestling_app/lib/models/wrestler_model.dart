class Wrestler {
  final String wrestlerUUID;
  final String? coachUUID;
  final String? wrestlingClubUUID;
  final String wrestlingStyle;

  Wrestler({
    required this.wrestlerUUID,
    this.coachUUID,
    this.wrestlingClubUUID,
    required this.wrestlingStyle,
  });

  factory Wrestler.fromJson(Map<String, dynamic> json) {
    return Wrestler(
      wrestlerUUID: json['wrestler_UUID'],
      coachUUID: json['coach_UUID'],
      wrestlingClubUUID: json['wrestling_club_UUID'],
      wrestlingStyle: json['wrestling_style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrestler_UUID': wrestlerUUID,
      'coach_UUID': coachUUID,
      'wrestling_club_UUID': wrestlingClubUUID,
      'wrestling_style': wrestlingStyle,
    };
  }
}
