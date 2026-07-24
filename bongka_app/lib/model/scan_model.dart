import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import 'threat_model.dart';

class ScanModel {
  final String id;
  final String userId;
  final String messageText;
  final int riskScore;
  final String riskLevel;
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'messageText': messageText,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'threats': threats.map((t) => t.toMap()).toList(),
      'suspiciousLinks': suspiciousLinks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ScanModel.fromMap(String id, Map<String, dynamic> map) {
    List<ThreatModel> threatList = [];
    if (map['threats'] != null) {
      for (var t in map['threats']) {
        threatList.add(ThreatModel.fromMap(t));
      }
    }

    DateTime date;
    if (map['createdAt'] is Timestamp) {
      date = (map['createdAt'] as Timestamp).toDate();
    } else {
      date = DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now();
    }

    return ScanModel(
      id: id,
      userId: map['userId'] ?? '',
      messageText: map['messageText'] ?? '',
      riskScore: map['riskScore'] ?? 0,
      riskLevel: map['riskLevel'] ?? 'SAFE',
      threats: threatList,
      suspiciousLinks: List<String>.from(map['suspiciousLinks'] ?? []),
      createdAt: date,
    );
  }

  // Extra info used by the UI, based on this scan's own data.
  Color get riskColor {
    if (riskLevel == 'HIGH') return AppColors.redColor;
    if (riskLevel == 'MEDIUM') return AppColors.yellowColor;
    return AppColors.greenColor;
  }

  String get riskLabel {
    if (riskLevel == 'MEDIUM') return 'MED';
    return riskLevel;
  }

  String get recommendation {
    if (riskLevel == 'HIGH') {
      return 'Do not click any links or reply. Delete it and report as phishing.';
    }
    if (riskLevel == 'MEDIUM') {
      return 'Be cautious. Verify the sender through another channel before acting.';
    }
    return 'No major threats found, but always check the sender and headers.';
  }

  String get safeBrowsingSummary {
    bool confirmed = false;
    for (var t in threats) {
      if (t.type == 'confirmedPhishing') confirmed = true;
    }

    if (confirmed) {
      return 'Google Safe Browsing confirmed a malicious link in this message.';
    }
    if (suspiciousLinks.isNotEmpty) {
      return 'Google Safe Browsing found no match for these links. This does not guarantee they are safe.';
    }
    return 'No links were found to check.';
  }

  String get reportText {
    String threatsText = 'No threats detected.';
    if (threats.isNotEmpty) {
      List<String> lines = [];
      for (var t in threats) {
        lines.add('${t.severity}: ${t.description}');
      }
      threatsText = lines.join('\n');
    }

    String linksText = 'None found.';
    if (suspiciousLinks.isNotEmpty) {
      linksText = suspiciousLinks.join('\n');
    }

    return 'BONGKA REPORT\n'
        'Date: $createdAt\n'
        'Risk Score: $riskScore/100 ($riskLevel)\n\n'
        'Scanned content:\n$messageText\n\n'
        'Threats (${threats.length}):\n$threatsText\n\n'
        'Suspicious URLs:\n$linksText\n\n'
        'Recommendation:\n$recommendation';
  }
}
