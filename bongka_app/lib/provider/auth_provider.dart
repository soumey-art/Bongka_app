import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  UserModel? currentUser;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => _authRepo.getCurrentUser() != null;

  // Called once at app startup. Firebase keeps you signed in across
  // restarts by itself, but this app's session state (currentUser)
  // also needs to be reloaded from Firestore so the rest of the app
  // behaves correctly right after a cold start.
  //
  // Returns:
  //   null  -> nobody is signed in, go to Signup/Login
  //   user  -> already signed in, go straight to Home
  Future<UserModel?> tryAutoLogin() async {
    isLoading = true;
    notifyListeners();
    try {
      currentUser = await _authRepo.restoreSession();
      return currentUser;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // SIGN IN
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      currentUser = await _authRepo.signIn(email, password);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // REGISTER
  Future<void> register(String email, String password, String name) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      currentUser = await _authRepo.register(email, password, name);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _authRepo.signOut();
    currentUser = null;
    notifyListeners();
  }

  // CHANGE PASSWORD
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _authRepo.changePassword(currentPassword, newPassword);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE score locally after scan — so UI updates immediately
  void updateLocalScore(int newScore) {
    if (currentUser != null) {
      currentUser = UserModel(
        id: currentUser!.id,
        email: currentUser!.email,
        displayName: currentUser!.displayName,
        cyberSafetyScore: newScore,
      );
      notifyListeners();
    }
  }
}
