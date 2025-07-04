import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/expense_service.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> _fetchAllExpenses() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    final groups = await GroupService.getUserGroups(user['username']);
    List expenses = [];
    for (final group in groups) {
      final groupExpenses =
          await ExpenseService.getExpensesByGroup(group['_id']);
      for (final e in groupExpenses) {
        expenses.add({...e, 'groupName': group['name']});
      }
    }
    expenses.sort((a, b) => b['date'].compareTo(a['date']));
    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    String selectedDate = 'All';
    final dateOptions = [
      'All',
      '2024-06-10',
      '2024-06-09',
      '2024-06-08',
      '2024-06-07'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Expense History')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedDate,
                  items: dateOptions.map((date) {
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (value) {}, // UI only
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchAllExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final expenses = snapshot.data ?? [];
                  if (expenses.isEmpty) {
                    return const Center(child: Text('No expenses found.'));
                  }
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final color =
                          index % 2 == 0 ? Colors.green[50] : Colors.blue[50];
                      return Card(
                        color: color,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.green),
                          title: Text(
                              '${expense['title']} (${expense['groupName']})'),
                          subtitle: Text(
                              'Paid by: ${expense['paidBy']} • ${expense['date'].toString().split('T')[0]}'),
                          trailing: Text('Rs. ${expense['amount']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
