class UserModel {
  final int userUUID;
  final String userEmail;
  final String userFullName;
  final String userType; // Wrestling Club, Referee, Coach, Wrestler
  final String? fcmToken; // Nullable token

  UserModel({
    required this.userUUID,
    required this.userEmail,
    required this.userFullName,
    required this.userType,
    this.fcmToken,
  });

  // Factory constructor to create an instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userUUID: json['user_UUID'] as int,
      userEmail: json['user_email'] as String,
      userFullName: json['user_full_name'] as String,
      userType: json['user_type'] as String,
      fcmToken: json['fcm_token'] != null ? json['fcm_token'] as String : null, // Handling nullable value
    );
  }

  // Convert object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'user_UUID': userUUID,
      'user_email': userEmail,
      'user_full_name': userFullName,
      'user_type': userType,
      if (fcmToken != null) 'fcm_token': fcmToken, // Only add if not null
    };
  }
}
