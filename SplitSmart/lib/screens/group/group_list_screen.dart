import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Your Groups')),
      body: FutureBuilder<List<dynamic>>(
        future: GroupService.getUserGroups(user['username']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(child: Text('No groups found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(group['name'][0]),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(group['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Wrap(
                    spacing: 8,
                    children: (group['memberUsernames'] as List)
                        .map((m) => Chip(
                              label: Text(m),
                              backgroundColor: Colors.blue[50],
                            ))
                        .toList(),
                  ),
                  trailing: group['adminUsername'] == user['username']
                      ? const Icon(Icons.admin_panel_settings,
                          color: Colors.blue)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(group: group),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-group'),
        child: const Icon(Icons.add),
        tooltip: 'Create Group',
      ),
    );
  }
}
