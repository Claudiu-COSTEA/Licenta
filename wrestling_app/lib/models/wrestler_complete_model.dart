// file: lib/models/wrestler_model.dart
class WrestlerCompleteModel {
  final int uuid;
  final String name;
  final String style;                // Greco Roman / Freestyle / Women
  final int coachUuid;
  final DateTime registeredAt;
  final String? medicalDocUrl;       // poate fi null
  final String? licenseDocUrl;       // poate fi null

  WrestlerCompleteModel({
    required this.uuid,
    required this.name,
    required this.style,
    required this.coachUuid,
    required this.registeredAt,
    this.medicalDocUrl,
    this.licenseDocUrl,
  });

  /// Construiește obiectul din harta JSON venită de la API
  factory WrestlerCompleteModel.fromJson(Map<String, dynamic> json) {
    return WrestlerCompleteModel(
      uuid         : json['wrestler_UUID']            as int,
      name         : json['wrestler_name']            as String,
      style        : json['wrestling_style']          as String,
      coachUuid    : json['coach_UUID']               as int,
      registeredAt : DateTime.tryParse(
          json['date_of_registration'] ?? ''
      ) ?? DateTime(2000),
      medicalDocUrl : json['medical_document'] as String?,
      licenseDocUrl : json['license_document'] as String?,
    );
  }

  /// Conversie inversă – utilă la upload / serializare locală
  Map<String, dynamic> toJson() => {
    'wrestler_UUID'          : uuid,
    'wrestler_name'          : name,
    'wrestling_style'        : style,
    'coach_UUID'             : coachUuid,
    'date_of_registration'   : registeredAt.toIso8601String(),
    'medical_document'       : medicalDocUrl,
    'license_document'       : licenseDocUrl,
  };

  @override
  String toString() =>
      'Wrestler($uuid, $name, $style, coach=$coachUuid)';
}
