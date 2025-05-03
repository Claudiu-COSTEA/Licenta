// models/competition.dart
class Competition {
  final int uuid;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String status;

  Competition({
    required this.uuid,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
  });

  /// Creează un obiect Competition dintr-un JSON Map
  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      uuid: json['competition_UUID'] as int,
      name: json['competition_name'] as String,
      startDate: DateTime.parse(json['competition_start_date'] as String),
      endDate: DateTime.parse(json['competition_end_date'] as String),
      location: json['competition_location'] as String,
      status: json['competition_status'] as String,
    );
  }

  /// Convertește obiectul Competition în JSON Map
  Map<String, dynamic> toJson() => {
    'competition_UUID': uuid,
    'competition_name': name,
    'competition_start_date': startDate.toIso8601String(),
    'competition_end_date': endDate.toIso8601String(),
    'competition_location': location,
    'competition_status': status,
  };

  @override
  String toString() {
    return 'Competition(uuid: $uuid, name: $name, startDate: $startDate, endDate: $endDate, location: $location, status: $status)';
  }
}