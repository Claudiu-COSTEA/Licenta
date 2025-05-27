class WrestlerDocuments {
  final String? medicalDocument;
  final String? licenseDocument;
  final int?    wrestlerUUID;          // ← new

  const WrestlerDocuments({
    this.medicalDocument,
    this.licenseDocument,
    this.wrestlerUUID,
  });

  factory WrestlerDocuments.fromJson(Map<String, dynamic> json) {
    return WrestlerDocuments(
      medicalDocument: json['medical_document'] as String?,
      licenseDocument: json['license_document'] as String?,
      wrestlerUUID: json['wrestler_UUID'] is int
          ? json['wrestler_UUID'] as int                // already an int
          : int.tryParse(json['wrestler_UUID']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'medical_document': medicalDocument,
    'license_document': licenseDocument,
    'wrestler_UUID'   : wrestlerUUID,
  };
}
