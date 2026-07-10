class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int cyberSafetyScore;
  final String? pinHash;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.cyberSafetyScore,
    this.pinHash
  });

  // Used when SAVING to Firestore (CREATE)
  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'cyberSafetyScore': cyberSafetyScore,
    if(pinHash != null) 'pinHash' : pinHash,
  };

  // Used when READING from Firestore (READ)
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      cyberSafetyScore: map['cyberSafetyScore'] ?? 100,
      pinHash: map['pinHash'] as String?,
    );
  }
}
