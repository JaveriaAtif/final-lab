import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../models/group.dart';

const String baseUrl = 'http://localhost:5000/api';

class ExpenseService {
  static Future<List<dynamic>> getExpensesByGroup(String groupId) async {
    final res = await http.get(Uri.parse('$baseUrl/expenses/group/$groupId'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  static Future<bool> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required DateTime date,
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/expenses/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'groupId': groupId,
        'title': title,
        'amount': amount,
        'paidBy': paidBy,
        'date': date.toIso8601String(),
        'notes': notes,
      }),
    );
    return res.statusCode == 201;
  }

  static Future<bool> deleteExpense(String expenseId) async {
    final res = await http.delete(Uri.parse('$baseUrl/expenses/$expenseId'));
    return res.statusCode == 200;
  }

  static Future<bool> editExpense(
      String expenseId, Map<String, dynamic> updates) async {
    final res = await http.put(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
    return res.statusCode == 200;
  }

  static Future<Map<String, double>> calculateBalances(Group group) async {
    final members = group.memberUsernames;
    final expenses = await getExpensesByGroup(group.id);
    final balances = {for (var m in members) m: 0.0};
    for (final expense in expenses) {
      final split = expense['amount'] / members.length;
      for (final member in members) {
        if (member == expense['paidBy']) {
          balances[member] = balances[member]! + (expense['amount'] - split);
        } else {
          balances[member] = balances[member]! - split;
        }
      }
    }
    return balances;
  }
}
