import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';
import 'auth_service.dart';

const String baseUrl = 'http://localhost:5000/api';

class GroupService {
  static Future<List<dynamic>> getUserGroups(String username) async {
    final res = await http.get(Uri.parse('$baseUrl/groups/user/$username'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> createGroup(String name) async {
    final user = AuthService.currentUser;
    if (user == null) return null;
    final res = await http.post(
      Uri.parse('$baseUrl/groups/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'adminUsername': user['username']}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    return null;
  }

  static Future<bool> inviteUser(String groupId, String username) async {
    final res = await http.post(
      Uri.parse('$baseUrl/groups/invite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'groupId': groupId, 'username': username}),
    );
    return res.statusCode == 200;
  }

  Future<void> acceptInvite(String inviteId) async {
    // TODO: Implement invite acceptance
  }
}
