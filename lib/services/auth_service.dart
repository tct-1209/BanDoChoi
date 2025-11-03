import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  
  // Mock users database
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'email': 'admin@toyshop.com',
      'password': 'admin123',
      'name': 'Admin User',
      'phone': '0123456789',
      'role': 'admin',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'email': 'user@example.com',
      'password': 'user123',
      'name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'role': 'customer',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    final userMap = _mockUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      throw Exception('Email hoặc mật khẩu không đúng');
    }

    final user = User.fromJson(userMap);
    await _saveUser(user);
    return user;
  }

  Future<User> register(String email, String password, String name, String? phone) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if email already exists
    final exists = _mockUsers.any((u) => u['email'] == email);
    if (exists) {
      throw Exception('Email đã được sử dụng');
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': 'customer',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _mockUsers.add(newUser);
    final user = User.fromJson(newUser);
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<User> updateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _saveUser(user);
    return user;
  }
}
