import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user_model.dart';
import '../service/firestore_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // REGISTER — creates new account
  Future<UserModel> register(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    final user = UserModel(
      id: credential.user!.uid,
      email: email,
      displayName: name,
      cyberSafetyScore: 100,
    );
    await _firestore.saveUser(user);
    return user;
  }

  // LOGIN — sign in existing user
  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    // Self-heal: if this account has no Firestore profile yet
    // (e.g. it was created manually in the console for testing),
    // create one now. Otherwise just stamp the login time so
    // there's a visible write to check in the console every time.
    final existing = await _firestore.getUser(uid);
    final user =
        existing ??
        UserModel(
          id: uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName ?? '',
          cyberSafetyScore: 100,
        );

    if (existing == null) {
      await _firestore.saveUser(user);
    } else {
      await _firestore.touchLastLogin(uid);
    }

    return user;
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // GET current user — check if already logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // RESTORE SESSION — Firebase Auth persists the login across app
  // restarts on its own, but our UserModel lives in Firestore and was
  // only ever loaded into memory during signIn()/register(). Without
  // this, reopening the app "loses" that profile data because nothing
  // re-fetches it on startup. Call this once when the app launches.
  Future<UserModel?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.getUser(user.uid);
  }

  // CHANGE PASSWORD — reauthenticates with the current password, then
  // updates to the new one. Firebase requires a recent sign-in before
  // allowing a password change, so we reauthenticate first.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('No signed-in user to change the password for.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
