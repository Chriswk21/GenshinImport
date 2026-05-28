import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  
  Future<bool> loginOAuth(String provider, String email, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.loginOAuth(provider, email, name);

    _isLoading = false;
    if (result['success'] == true) {
      _token = result['token'];
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'External OAuth failed.';
      notifyListeners();
      return false;
    }
  }

  
  void logout() {
    _token = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}
