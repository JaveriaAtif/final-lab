import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({Key? key}) : super(key: key);

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Group')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter group name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                    labelText: 'Initial Amount (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final group =
                        await GroupService.createGroup(_nameController.text);
                    if (group != null && _amountController.text.isNotEmpty) {
                      final amount =
                          double.tryParse(_amountController.text) ?? 0.0;
                      if (amount > 0) {
                        await ExpenseService.addExpense(
                          groupId: group['_id'],
                          title: 'Initial Amount',
                          amount: amount,
                          paidBy: AuthService.currentUser!['username'],
                          date: DateTime.now(),
                          notes: 'Initial amount on group creation',
                        );
                      }
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
