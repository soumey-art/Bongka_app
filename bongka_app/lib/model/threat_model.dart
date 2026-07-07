class ThreatModel {
  final String type;
  final String description;
  final String severity; // HIGH / MEDIUM / LOW

  ThreatModel({
    required this.type,
    required this.description,
    required this.severity,
  });

  // Used when SAVING to Firestore
  Map<String, dynamic> toMap() => {
    'type': type,
    'description': description,
    'severity': severity,
  };

  // Used when READING from Firestore
  factory ThreatModel.fromMap(Map<String, dynamic> map) {
    return ThreatModel(
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'LOW',
    );
  }
}
