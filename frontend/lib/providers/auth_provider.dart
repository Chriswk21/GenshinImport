import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';

const String googleWebClientId = '373612843176-5t4aoh147burk9hsksk4076lctie05b6.apps.googleusercontent.com';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb ? googleWebClientId : null,
  serverClientId: kIsWeb ? null : googleWebClientId,
  scopes: ['email', 'profile'],
);

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user != null && _user!['role'] == 'Admin';

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.login(email, password);

    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Login failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.register(name, email, password);

    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        _errorMessage = 'Google Sign-In was cancelled.';
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _isLoading = false;
        _errorMessage = 'Failed to retrieve Google ID token.';
        notifyListeners();
        return false;
      }

      final result = await ApiService.loginWithGoogle(
        idToken,
        googleUser.email,
        googleUser.displayName ?? 'Traveler',
      );

      _isLoading = false;
      if (result['success'] == true) {
        _token = result['token'];
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Google Sign-In failed.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Google Sign-In error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  void logout() {
    signOutGoogle();
    _token = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
