// lib/models/referee_model.dart
class RefereeCompleteModel {
  final int uuid;                 // referee_UUID
  final String fullName;          // user_full_name
  final String wrestlingStyle;    // wrestling_style

  RefereeCompleteModel({
    required this.uuid,
    required this.fullName,
    required this.wrestlingStyle,
  });

  /// Construiește un obiect dintr-un map JSON
  factory RefereeCompleteModel.fromJson(Map<String, dynamic> json) => RefereeCompleteModel(
    uuid: json['referee_UUID'] as int,
    fullName: json['user_full_name'] as String,
    wrestlingStyle: json['wrestling_style'] as String,
  );

  /// În caz că vrei să trimiți modelul înapoi spre server
  Map<String, dynamic> toJson() => {
    'referee_UUID'   : uuid,
    'user_full_name' : fullName,
    'wrestling_style': wrestlingStyle,
  };

  @override
  String toString() =>
      'Referee($uuid, $fullName, $wrestlingStyle)';
}
