class UserModel {
  final int userUUID; // Cannot be null (Primary Key)
  final String userEmail; // Cannot be null
  final String userFullName; // Cannot be null
  final String userType; // Cannot be null
  final String? fcmToken; // Nullable field

  UserModel({
    required this.userUUID,
    required this.userEmail,
    required this.userFullName,
    required this.userType,
    this.fcmToken,
  });

  // ✅ Factory constructor to parse JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userUUID: json['user_UUID'] as int, // Enforced non-null
      userEmail: json['user_email'] as String,
      userFullName: json['user_full_name'] as String,
      userType: json['user_type'] as String,
      fcmToken: json['fcm_token'], // Nullable field
    );
  }

  // Convert object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'user_UUID': userUUID,
      'user_email': userEmail,
      'user_full_name': userFullName,
      'user_type': userType,
      if (fcmToken != null) 'fcm_token': fcmToken, // Only include if not null
    };
  }
}
