class ThreatModel {
  final String type;
  final String description;
  final String severity; // HIGH / MEDIUM / LOW

  ThreatModel({
    required this.type,
    required this.description,
    required this.severity,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'description': description,
    'severity': severity,
  };

  factory ThreatModel.fromMap(Map<String, dynamic> map) {
    return ThreatModel(
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'LOW',
    );
  }

  String get explanation {
    switch (type) {
      case 'urgencyLanguage':
        return 'Uses urgency language to pressure you into acting fast';
      case 'genericGreeting':
        return 'Uses a generic greeting instead of your real name';
      case 'credentialRequest':
        return 'Asks for a password, PIN, or code — real companies do not ask this way';
      case 'lookalikeDomain':
        return 'Link domain looks like a trusted brand but isn\'t';
      case 'confirmedPhishing':
        return 'A link was confirmed malicious by Google Safe Browsing';
      case 'replyToMismatch':
        return 'Reply-To address does not match the sender';
      case 'returnPathMismatch':
        return 'Return-Path does not match the sender address';
      case 'spfFail':
        return 'Failed SPF check — sending server is not authorized for this domain';
      case 'dkimFail':
        return 'Failed DKIM check — message may have been altered';
      case 'dmarcFail':
        return 'Failed DMARC check — fails domain anti-spoofing policy';
      default:
        return description;
    }
  }
}
