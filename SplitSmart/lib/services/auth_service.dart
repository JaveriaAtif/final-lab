import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:5000/api';

class AuthService {
  static String? _token;
  static Map<String, dynamic>? _currentUser;

  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get token => _token;

  static Future<bool> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'username': username, 'email': email, 'password': password}),
    );
    return res.statusCode == 201;
  }

  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['token'];
      _currentUser = data['user'];
      return true;
    }
    return false;
  }

  static void logout() {
    _token = null;
    _currentUser = null;
  }

  static Future<Map<String, dynamic>?> getUserByUsername(
      String username) async {
    // Not implemented in backend, so return null for now
    return null;
  }

  static Future<bool> editProfile(
      {required String newUsername, required String newEmail}) async {
    // Not implemented in backend, so return false for now
    return false;
  }

  static Future<bool> resetPassword(
      {required String username, required String newPassword}) async {
    // Not implemented in backend, so return false for now
    return false;
  }
}
