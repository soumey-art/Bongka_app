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

  //SAVE PIN- persists a hashed PIN for the current user
  Future<void> savePin(String hashedPin) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user to save a PIN for.');
    }
    await _firestore.savePinHash(user.uid, hashedPin);
  }
}
