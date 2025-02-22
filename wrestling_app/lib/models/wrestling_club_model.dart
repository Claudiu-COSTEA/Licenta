class WrestlingClub {
  final int wrestlingClubUUID;
  final String wrestlingClubLocation;

  WrestlingClub({
    required this.wrestlingClubUUID,
    required this.wrestlingClubLocation,
  });

  factory WrestlingClub.fromJson(Map<String, dynamic> json) {
    return WrestlingClub(
      wrestlingClubUUID: json['wrestling_club_UUID'],
      wrestlingClubLocation: json['wrestling_club_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrestling_club_UUID': wrestlingClubUUID,
      'wrestling_club_location': wrestlingClubLocation,
    };
  }
}
