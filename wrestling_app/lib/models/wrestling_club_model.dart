// models/wrestling_club.dart
class WrestlingClub {
  final int uuid;
  final String clubName;
  final String city;
  final double latitude;
  final double longitude;

  WrestlingClub({
    required this.uuid,
    required this.clubName,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  /// Construiește din JSON (map venit de la API)
  factory WrestlingClub.fromJson(Map<String, dynamic> json) {
    return WrestlingClub(
      uuid: json['wrestling_club_UUID'] as int,
      clubName: json['club_name'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Invers – dacă vrei să trimiți înapoi spre server
  Map<String, dynamic> toJson() => {
    'wrestling_club_UUID': uuid,
    'club_name': clubName,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  String toString() =>
      'WrestlingClub($uuid, $clubName, $city, $latitude, $longitude)';
}