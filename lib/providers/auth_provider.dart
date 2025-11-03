import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/auth_api_service.dart';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;

  // Initialize auth state from storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConfig.userDataKey);
      final token = prefs.getString(AppConfig.userTokenKey);

      if (userJson != null && token != null) {
        final userMap = json.decode(userJson);
        _user = User.fromJson(userMap);
        _token = token;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await _clearAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = User.fromJson(response.data!['user']);
        _token = response.data!['token'];
        
        await _saveAuthData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String phoneNumber,
    required String password,
    required String email,
    required String fullname,
    String? address,
    String roleName = 'customer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.register(
        phoneNumber: phoneNumber,
        password: password,
        email: email,
        fullname: fullname,
        address: address,
        roleName: roleName,
      );

      if (response.success && response.data != null) {
        _user = User.fromJson(response.data!['user']);
        // Note: Register không trả về token, cần login lại
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearAuthData();
      _user = null;
      _token = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.updateUserProfile(
        userId: _user!.id.toString(),
        token: _token!,
        userData: userData,
      );

      if (response.success && response.data != null) {
        _user = response.data!;
        await _saveAuthData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_user == null || _token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.changePassword(
        userId: _user!.id.toString(),
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.forgotPassword(email: email);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthApiService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private methods
  Future<void> _saveAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString(AppConfig.userDataKey, json.encode(_user!.toJson()));
      }
      if (_token != null) {
        await prefs.setString(AppConfig.userTokenKey, _token!);
      }
      await prefs.setBool(AppConfig.isLoggedInKey, isLoggedIn);
    } catch (e) {
      debugPrint('Error saving auth data: $e');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.userDataKey);
      await prefs.remove(AppConfig.userTokenKey);
      await prefs.remove(AppConfig.isLoggedInKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }
}
