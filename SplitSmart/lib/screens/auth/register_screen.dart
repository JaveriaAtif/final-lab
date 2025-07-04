import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '', email = '', password = '';
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (v) => username = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter username' : null,
              ),
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
                    v == null || v.length < 6 ? 'Min 6 chars' : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success =
                        await AuthService.register(username, email, password);
                    if (success) {
                      Navigator.pop(context);
                    } else {
                      setState(() => error = 'User already exists');
                    }
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
