import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/expense_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    final user = AuthService.currentUser;
    if (user == null)
      return {'groups': 0, 'expenses': 0, 'outstanding': 0, 'recent': []};
    final groups = await GroupService.getUserGroups(user['username']);
    int totalGroups = groups.length;
    int totalExpenses = 0;
    int outstanding = 0;
    List recentExpenses = [];
    for (final group in groups) {
      final expenses = await ExpenseService.getExpensesByGroup(group['_id']);
      totalExpenses +=
          expenses.fold(0, (sum, e) => sum + (e['amount'] as num).toInt());
      recentExpenses
          .addAll(expenses.map((e) => {'expense': e, 'group': group}));
      for (final expense in expenses) {
        if (expense['paidBy'] != user['username']) {
          outstanding += ((expense['amount'] as num) /
                  (group['memberUsernames'] as List).length)
              .toInt();
        }
      }
    }
    recentExpenses
        .sort((a, b) => b['expense']['date'].compareTo(a['expense']['date']));
    return {
      'groups': totalGroups,
      'expenses': totalExpenses,
      'outstanding': outstanding,
      'recent': recentExpenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchDashboardStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final stats = snapshot.data ??
                {'groups': 0, 'expenses': 0, 'outstanding': 0, 'recent': []};
            final recentExpenses = stats['recent'] as List;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DashboardCard(
                      icon: Icons.group,
                      label: 'Total Groups',
                      value: '${stats['groups']}',
                      color: Colors.blueAccent,
                    ),
                    _DashboardCard(
                      icon: Icons.attach_money,
                      label: 'Total Expenses',
                      value: 'Rs. ${stats['expenses']}',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DashboardCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Outstanding',
                      value: 'Rs. ${stats['outstanding']}',
                      color: Colors.redAccent,
                    ),
                    _DashboardCard(
                      icon: Icons.history,
                      label: 'Recent Activity',
                      value: '${recentExpenses.length}',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Recent Activity',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        recentExpenses.length > 10 ? 10 : recentExpenses.length,
                    itemBuilder: (context, index) {
                      final exp = recentExpenses[index]['expense'];
                      final group = recentExpenses[index]['group'];
                      return ListTile(
                        leading:
                            const Icon(Icons.attach_money, color: Colors.green),
                        title: Text(
                            'You paid "${exp['title']}" in ${group['name']}'),
                        subtitle: Text(
                            'Rs. ${exp['amount']} • ${exp['date'].toString().split('T')[0]}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.1),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4 - 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
