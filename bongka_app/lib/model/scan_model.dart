import 'threat_model.dart';

class ScanModel {
  final String id;
  final String userId;
  final String messageText;
  final int riskScore;
  final String riskLevel; // HIGH / MEDIUM / SAFE
  final List<ThreatModel> threats;
  final List<String> suspiciousLinks;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.userId,
    required this.messageText,
    required this.riskScore,
    required this.riskLevel,
    required this.threats,
    required this.suspiciousLinks,
    required this.createdAt,
  });

  // Used when SAVING to Firestore (CREATE)
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'messageText': messageText,
    'riskScore': riskScore,
    'riskLevel': riskLevel,
    'threats': threats.map((t) => t.toMap()).toList(),
    'suspiciousLinks': suspiciousLinks,
    'createdAt': createdAt.toIso8601String(),
  };

  // Used when READING from Firestore (READ)
  factory ScanModel.fromMap(String id, Map<String, dynamic> map) {
    return ScanModel(
      id: id,
      userId: map['userId'] ?? '',
      messageText: map['messageText'] ?? '',
      riskScore: map['riskScore'] ?? 0,
      riskLevel: map['riskLevel'] ?? 'SAFE',
      threats: (map['threats'] as List? ?? [])
          .map((t) => ThreatModel.fromMap(t))
          .toList(),
      suspiciousLinks: List<String>.from(map['suspiciousLinks'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
