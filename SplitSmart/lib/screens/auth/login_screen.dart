import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter password' : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await AuthService.login(email, password);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      setState(() => error = 'Invalid credentials');
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
              TextButton(
                onPressed: () async {
                  final usernameController = TextEditingController();
                  final passwordController = TextEditingController();
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration:
                                const InputDecoration(labelText: 'Username'),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                                labelText: 'New Password'),
                            obscureText: true,
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
                            final success = await AuthService.resetPassword(
                              username: usernameController.text,
                              newPassword: passwordController.text,
                            );
                            Navigator.pop(context, success);
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset!')),
                    );
                  } else if (result == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found!')),
                    );
                  }
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
