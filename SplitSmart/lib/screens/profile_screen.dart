import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';
import '../services/expense_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchProfileStats() async {
    final user = AuthService.currentUser;
    if (user == null) return {'groups': 0, 'spent': 0, 'received': 0};
    final groups = await GroupService.getUserGroups(user['username']);
    int totalSpent = 0;
    int totalReceived = 0;
    for (final group in groups) {
      final expenses = await ExpenseService.getExpensesByGroup(group['_id']);
      for (final expense in expenses) {
        if (expense['paidBy'] == user['username']) {
          totalSpent += (expense['amount'] as num).toInt();
        } else {
          totalReceived += ((expense['amount'] as num) /
                  (group['memberUsernames'] as List).length)
              .toInt();
        }
      }
    }
    return {
      'groups': groups.length,
      'spent': totalSpent,
      'received': totalReceived,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user['username'],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user['email'], style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchProfileStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stats =
                    snapshot.data ?? {'groups': 0, 'spent': 0, 'received': 0};
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(
                        label: 'Groups', value: stats['groups'].toString()),
                    _ProfileStat(
                        label: 'Spent', value: 'Rs. ${stats['spent']}'),
                    _ProfileStat(
                        label: 'Received', value: 'Rs. ${stats['received']}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Joined'),
              trailing: Text('N/A'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                final usernameController =
                    TextEditingController(text: user['username']);
                final emailController =
                    TextEditingController(text: user['email']);
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final success = await AuthService.editProfile(
                            newUsername: usernameController.text,
                            newEmail: emailController.text,
                          );
                          Navigator.pop(context, success);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                  (context as Element).markNeedsBuild();
                } else if (result == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Username or email already exists!')),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
