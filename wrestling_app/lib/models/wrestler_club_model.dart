class WrestlingClub {
  final String clubUUID;
  final String clubName;

  WrestlingClub({
    required this.clubUUID,
    required this.clubName,
  });

  factory WrestlingClub.fromJson(Map<String, dynamic> json) {
    return WrestlingClub(
      clubUUID: json['wrestling_club_UUID'],
      clubName: json['wrestling_club_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrestling_club_UUID': clubUUID,
      'wrestling_club_name': clubName,
    };
  }
}
