import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user_model.dart';

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
}
