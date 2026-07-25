import '../../model/scan_model.dart';
import '../../model/threat_model.dart';

class PhishingDetectorService {
  ScanModel analyze(String message, String userId) {
    final List<ThreatModel> threats = [];
    final List<String> suspiciousLinks = [];

    // STEP 1 — urgency keywords
    const urgencyWords = [
      'verify now',
      'account suspended',
      'click immediately',
      'limited time',
      'urgent action',
      'your account will be closed',
      'confirm your identity',
      'act now',
      'update your information',
      'login immediately',
      'verify your account',
      'security alert',
    ];
    for (final word in urgencyWords) {
      if (message.toLowerCase().contains(word)) {
        threats.add(
          ThreatModel(
            type: 'urgencyLanguage',
            description: 'Urgency language detected: "$word"',
            severity: 'HIGH',
          ),
        );
        break;
      }
    }

    // STEP 2 — generic greeting
    if (message.toLowerCase().contains('dear customer') ||
        message.toLowerCase().contains('dear user') ||
        message.toLowerCase().contains('dear account holder')) {
      threats.add(
        ThreatModel(
          type: 'genericGreeting',
          description: 'Generic greeting — real companies use your name',
          severity: 'MEDIUM',
        ),
      );
    }

    // STEP 3 — extract URLs from message
    final urlRegex = RegExp(r'https?://[^\s]+');
    final urls = urlRegex.allMatches(message).map((m) => m.group(0)!).toList();

    // STEP 4 — lookalike domain check
    const knownBrands = [
      'paypal',
      'google',
      'facebook',
      'apple',
      'amazon',
      'netflix',
      'microsoft',
      'bank',
      'instagram',
      'dhl',
    ];
    for (final url in urls) {
      final domain = Uri.tryParse(url)?.host ?? '';
      for (final brand in knownBrands) {
        if (domain.contains(brand) &&
            domain != '$brand.com' &&
            domain != 'www.$brand.com') {
          if (!suspiciousLinks.contains(url)) {
            suspiciousLinks.add(url);
            threats.add(
              ThreatModel(
                type: 'lookalikeDomain',
                description: 'Lookalike domain detected: $domain',
                severity: 'HIGH',
              ),
            );
          }
        }
      }
    }

    // STEP 5 — email header analysis 
    threats.addAll(_analyzeHeaders(message));

    // STEP 6 — calculate risk score
    int score = 0;
    for (final t in threats) {
      if (t.severity == 'HIGH') score += 35;
      if (t.severity == 'MEDIUM') score += 20;
      if (t.severity == 'LOW') score += 10;
    }
    score = score.clamp(0, 100);
    final riskLevel = score >= 60
        ? 'HIGH'
        : score >= 30
        ? 'MEDIUM'
        : 'SAFE';

    return ScanModel(
      id: '',
      userId: userId,
      messageText: message,
      riskScore: score,
      riskLevel: riskLevel,
      threats: threats,
      suspiciousLinks: suspiciousLinks,
      createdAt: DateTime.now(),
    );
  }
  String? _extractDomain(String? headerValue) {
    if (headerValue == null) return null;
    final match = RegExp(r'[\w.\-+]+@([\w.\-]+)').firstMatch(headerValue);
    return match?.group(1)?.toLowerCase();
  }

  String? _headerValue(String text, String headerName) {
    final match = RegExp(
      '^$headerName'
      r':\s*(.+)$',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1)?.trim();
  }

  List<ThreatModel> _analyzeHeaders(String message) {
    final threats = <ThreatModel>[];

    final fromLine = _headerValue(message, 'From');
    if (fromLine == null) return threats;

    final replyToLine = _headerValue(message, 'Reply-To');
    final returnPathLine = _headerValue(message, 'Return-Path');
    final authResults = _headerValue(message, 'Authentication-Results');

    final fromDomain = _extractDomain(fromLine);
    final replyToDomain = _extractDomain(replyToLine);
    final returnPathDomain = _extractDomain(returnPathLine);

    if (fromDomain != null &&
        replyToDomain != null &&
        replyToDomain != fromDomain) {
      threats.add(
        ThreatModel(
          type: 'replyToMismatch',
          description:
              'From address ($fromDomain) does not match Reply-To address ($replyToDomain)',
          severity: 'HIGH',
        ),
      );
    }

    if (fromDomain != null &&
        returnPathDomain != null &&
        returnPathDomain != fromDomain) {
      threats.add(
        ThreatModel(
          type: 'returnPathMismatch',
          description:
              'From address ($fromDomain) does not match Return-Path ($returnPathDomain)',
          severity: 'MEDIUM',
        ),
      );
    }

    if (authResults != null) {
      final lower = authResults.toLowerCase();
      if (lower.contains('spf=fail') || lower.contains('spf=softfail')) {
        threats.add(
          ThreatModel(
            type: 'spfFail',
            description:
                'SPF check failed — sending server is not authorized for this domain',
            severity: 'HIGH',
          ),
        );
      }
      if (lower.contains('dkim=fail')) {
        threats.add(
          ThreatModel(
            type: 'dkimFail',
            description:
                'DKIM signature failed — message content or sender may have been altered',
            severity: 'HIGH',
          ),
        );
      }
      if (lower.contains('dmarc=fail')) {
        threats.add(
          ThreatModel(
            type: 'dmarcFail',
            description:
                'DMARC check failed — this message fails the domain\'s own anti-spoofing policy',
            severity: 'HIGH',
          ),
        );
      }
    }

    return threats;
  }
}
