import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/expense_service.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class GroupDetailScreen extends StatelessWidget {
  final Map group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  Future<List<dynamic>> _fetchExpenses() async {
    return await ExpenseService.getExpensesByGroup(group['_id']);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(group['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Expenses',
            onPressed: () async {
              final expenses =
                  await ExpenseService.getExpensesByGroup(group['_id']);
              final buffer = StringBuffer();
              buffer.writeln('Expenses for group: ${group['name']}\n');
              for (final e in expenses) {
                buffer.writeln(
                    'Title: ${e['title']}, Amount: Rs. ${e['amount']}, Paid by: ${e['paidBy']}, Date: ${e['date'].toString().split('T')[0]}, Notes: ${e['notes'] ?? ''}');
              }
              final directory = await getApplicationDocumentsDirectory();
              final file =
                  File('${directory.path}/${group['name']}_expenses.txt');
              await file.writeAsString(buffer.toString());
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to \\${file.path}')),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(group['name'][0],
                      style: const TextStyle(fontSize: 28)),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: (group['memberUsernames'] as List)
                        .map((m) => Chip(
                              label: Text(m),
                              backgroundColor: Colors.blue[50],
                            ))
                        .toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Invite Member',
                  onPressed: () async {
                    final usernameController = TextEditingController();
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Invite Member'),
                        content: TextField(
                          controller: usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, usernameController.text),
                            child: const Text('Invite'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      final success =
                          await GroupService.inviteUser(group['_id'], result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'User invited!'
                              : 'User not found or already in group'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Balances calculation is not possible without all expenses and members, so skip for now
            const SizedBox(height: 16),
            const Text('Recent Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchExpenses(),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.green),
                          title: Text(expense['title']),
                          subtitle: Text(
                              'Paid by: ${expense['paidBy']} • ${expense['date'].toString().split('T')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.orange),
                                onPressed: () async {
                                  final titleController = TextEditingController(
                                      text: expense['title']);
                                  final amountController =
                                      TextEditingController(
                                          text: expense['amount'].toString());
                                  final notesController = TextEditingController(
                                      text: expense['notes'] ?? '');
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Expense'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: titleController,
                                            decoration: const InputDecoration(
                                                labelText: 'Title'),
                                          ),
                                          TextField(
                                            controller: amountController,
                                            decoration: const InputDecoration(
                                                labelText: 'Amount'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextField(
                                            controller: notesController,
                                            decoration: const InputDecoration(
                                                labelText: 'Notes'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await ExpenseService.editExpense(
                                              expense['_id'],
                                              {
                                                'title': titleController.text,
                                                'amount': double.tryParse(
                                                        amountController
                                                            .text) ??
                                                    expense['amount'],
                                                'notes': notesController.text,
                                              },
                                            );
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Expense updated!')),
                                    );
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Expense'),
                                      content: const Text(
                                          'Are you sure you want to delete this expense?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ExpenseService.deleteExpense(
                                        expense['_id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Expense deleted!')),
                                    );
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }
}
