import 'package:flutter/material.dart';
import '../data/service/phishing_detector_service.dart';
import '../data/service/firestore_service.dart';
import '../data/repositories/phishing_repository.dart';
import '../model/scan_model.dart';
import '../model/threat_model.dart';
import '../model/report_model.dart';
import 'auth_provider.dart';

class ScanProvider extends ChangeNotifier {
  final PhishingDetectorService _detector = PhishingDetectorService();
  final FirestoreService _firestore = FirestoreService();
  final PhishingRepository _phishingRepo = PhishingRepository();

  ScanModel? currentResult;
  bool isLoading = false;
  String? error;

  // Reports screen state
  List<ScanModel> scans = [];
  ReportModel? stats;
  bool isLoadingReports = false;
  String? reportsError;

  // Home screen uses this for the "Recent Activity" live list.
  Stream<List<ScanModel>> recentScansStream(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _firestore.getRecentScans(userId);
  }

  Future<int?> getSavedScore(String userId) async {
    if (userId.isEmpty) return null;
    final user = await _firestore.getUser(userId);
    return user?.cyberSafetyScore;
  }

  // Reports screen calls this on load.
  Future<void> loadReports(String userId) async {
    isLoadingReports = true;
    reportsError = null;
    notifyListeners();

    if (userId.isEmpty) {
      isLoadingReports = false;
      notifyListeners();
      return;
    }

    try {
      stats = await _firestore.getUserStats(userId);
      scans = await _firestore.getAllScans(userId);
    } catch (e) {
      reportsError = 'Failed to load: $e';
    }

    isLoadingReports = false;
    notifyListeners();
  }

  Future<bool> deleteScan(ScanModel scan) async {
    scans.removeWhere((s) => s.id == scan.id);
    notifyListeners();

    try {
      await _firestore.deleteScan(scan.id);
      return true;
    } catch (e) {
      scans.add(scan); // put it back, delete failed
      reportsError = 'Could not delete scan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> analyzeMessage(
    String message,
    String userId,
    AuthProvider authProvider,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Step 1 — local rule engine
      ScanModel result = _detector.analyze(message, userId);

      // Step 2 — Google Safe Browsing API
      if (result.suspiciousLinks.isNotEmpty) {
        final badUrls = await _phishingRepo.checkUrls(result.suspiciousLinks);
        if (badUrls.isNotEmpty) {
          final extra = badUrls
              .map(
                (url) => ThreatModel(
                  type: 'confirmedPhishing',
                  description: 'Confirmed by Google Safe Browsing: $url',
                  severity: 'HIGH',
                ),
              )
              .toList();
          final allThreats = [...result.threats, ...extra];
          final boostedScore = (result.riskScore + 20).clamp(0, 100);
          result = ScanModel(
            id: result.id,
            userId: result.userId,
            messageText: result.messageText,
            riskScore: boostedScore,
            riskLevel: boostedScore >= 60
                ? 'HIGH'
                : boostedScore >= 30
                ? 'MEDIUM'
                : 'SAFE',
            threats: allThreats,
            suspiciousLinks: result.suspiciousLinks,
            createdAt: result.createdAt,
          );
        }
      }

      // Step 3 — CREATE: save scan to Firestore
      await _firestore.saveScan(result);

      // Step 4 — UPDATE: recalculate safety score
      final newScore = (100 - result.riskScore).clamp(0, 100);
      await _firestore.updateSafetyScore(userId, newScore);

      // Step 5 — update score in memory so UI updates instantly
      authProvider.updateLocalScore(newScore);

      currentResult = result;
    } catch (e) {
      error = 'Analysis failed: ${e.toString()}';
    }

    isLoading = false;
    notifyListeners();
  }

  // Used by the Reports screen when the user taps on an old scan —
  // loads that saved scan back into currentResult so
  // AnalysisResultScreen can display it again.
  void loadPastScan(ScanModel scan) {
    currentResult = scan;
    error = null;
    notifyListeners();
  }

  void reset() {
    currentResult = null;
    error = null;
    notifyListeners();
  }
}
