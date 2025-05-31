import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _apiBaseUrl = 'https://dummyjson.com';
  static const String _tokenKey = 'user_token';


  static final StreamController<bool> _loginStateController =
      StreamController<bool>.broadcast();


  static Stream<bool> get isLoggedInStream => _loginStateController.stream;

  static User? _currentUser;

  static User? get currentUser => _currentUser;


  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'password': password,
        }),
      );

      debugPrint('Login Response Status Code: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);

        _currentUser = User.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _currentUser?.token ?? '');

  
        _loginStateController.add(true);

        debugPrint('Login Successful. Token: ${_currentUser?.token}');
        return true;
      } else {
    
        _loginStateController.add(false);

        debugPrint('Login Failed. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
   
      _loginStateController.add(false);

      debugPrint('Login error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _currentUser = null;


    _loginStateController.add(false);
  }

  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

 
      final isLoggedIn = token != null && token.isNotEmpty;
      _loginStateController.add(isLoggedIn);

      return isLoggedIn;
    } catch (e) {
      debugPrint('Authentication check error: $e');
      _loginStateController.add(false);
      return false;
    }
  }

  static void dispose() {
    _loginStateController.close();
  }


  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }
}
