// lib/provider/auth_provider.dart
import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  UserModel? currentUser;
  bool isLoading = false;
  String? error;

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

  //SAVE PIN
  Future<void> savePin(String hashedPin) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _authRepo.savePin(hashedPin);
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

  // CHECK if already logged in
  bool get isLoggedIn => _authRepo.getCurrentUser() != null;
}
