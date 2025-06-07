class WrestlerDetails {
  final String wrestlerName;
  final String coachName;
  final String clubName;

  WrestlerDetails({
    required this.wrestlerName,
    required this.coachName,
    required this.clubName,
  });

  factory WrestlerDetails.fromJson(Map<String, dynamic> json) {
    return WrestlerDetails(
      wrestlerName: json['wrestler_name'] as String,
      coachName:    json['coach_name']    as String,
      clubName:     json['club_name']     as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrestler_name': wrestlerName,
      'coach_name':    coachName,
      'club_name':     clubName,
    };
  }
}
