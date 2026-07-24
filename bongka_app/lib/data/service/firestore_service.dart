import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user_model.dart';
import '../../model/scan_model.dart';
import '../../model/report_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // Create or overwrite a user's profile document.
  Future<void> saveUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Read a user's profile document. Returns null if it doesn't exist yet.
  Future<UserModel?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromMap(uid, snap.data()!);
  }

  // Stamp the current time onto an existing profile, proving a write
  // actually happened on this login.
  Future<void> touchLastLogin(String uid) async {
    await _users.doc(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> get _scans =>
      _db.collection('scans');

  // CREATE — save scan after analysis
  Future<void> saveScan(ScanModel scan) async {
    await _scans.add(scan.toMap());
  }

  // READ — last 5 scans for Home Dashboard (real-time)
  Stream<List<ScanModel>> getRecentScans(String userId) {
    return _scans
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ScanModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // READ — all scans for Reports screen
  Future<List<ScanModel>> getAllScans(String userId) async {
    final snap = await _scans
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => ScanModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // UPDATE — recalculate safety score after scan
  Future<void> updateSafetyScore(String userId, int newScore) async {
    await _users.doc(userId).update({'cyberSafetyScore': newScore});
  }

  // DELETE — remove a scan from history
  Future<void> deleteScan(String scanId) async {
    await _scans.doc(scanId).delete();
  }

  // STATS — calculate for Reports screen
  Future<ReportModel> getUserStats(String userId) async {
    final scans = await getAllScans(userId);
    if (scans.isEmpty) {
      return ReportModel(
        totalScans: 0,
        daysActive: 0,
        accuracy: 0,
        weeklyData: [0, 0, 0, 0, 0, 0, 0],
      );
    }
    final days = scans
        .map((s) => s.createdAt.toLocal().toString().substring(0, 10))
        .toSet();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekly = List<int>.filled(7, 0);
    for (var scan in scans) {
      final diff = scan.createdAt
          .difference(
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          )
          .inDays;
      if (diff >= 0 && diff < 7) weekly[diff]++;
    }
    final safeCount = scans.where((s) => s.riskLevel == 'SAFE').length;
    final accuracy = ((safeCount / scans.length) * 100).round();
    return ReportModel(
      totalScans: scans.length,
      daysActive: days.length,
      accuracy: accuracy,
      weeklyData: weekly,
    );
  }
}
