import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/group/group_list_screen.dart';
import 'screens/group/add_group_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/expense/expense_history_screen.dart';

void main() {
  runApp(const SplitSmartApp());
}

class SplitSmartApp extends StatelessWidget {
  const SplitSmartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitSmart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/groups': (context) => const GroupListScreen(),
        '/add-group': (context) => const AddGroupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/add-expense': (context) => const AddExpenseScreen(),
        '/expense-history': (context) => const ExpenseHistoryScreen(),
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('SplitSmart', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Groups'),
            onTap: () => Navigator.pushReplacementNamed(context, '/groups'),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Group'),
            onTap: () => Navigator.pushReplacementNamed(context, '/add-group'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Add Expense'),
            onTap: () => Navigator.pushReplacementNamed(context, '/add-expense'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Expense History'),
            onTap: () => Navigator.pushReplacementNamed(context, '/expense-history'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Register'),
            onTap: () => Navigator.pushReplacementNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
} 