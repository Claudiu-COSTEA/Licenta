class WrestlerDocuments {
  final String medicalDocument;
  final String licenseDocument;

  WrestlerDocuments({
    required this.medicalDocument,
    required this.licenseDocument,
  });

  factory WrestlerDocuments.fromJson(Map<String, dynamic> json) {
    return WrestlerDocuments(
      medicalDocument: json['medical_document'],
      licenseDocument: json['license_document'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medical_document': medicalDocument,
      'license_document': licenseDocument,
    };
  }
}
