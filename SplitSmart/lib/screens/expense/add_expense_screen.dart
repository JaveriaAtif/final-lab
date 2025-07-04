import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedMember;
  String? _selectedGroupId;
  List<dynamic> _groups = [];
  List<String> _members = [];
  DateTime _selectedDate = DateTime.now();

  Future<List<dynamic>> _fetchGroups() async {
    final user = AuthService.currentUser;
    if (user == null) return [];
    final groups = await GroupService.getUserGroups(user['username']);
    return groups;
  }

  void _onGroupChanged(String? groupId) {
    setState(() {
      _selectedGroupId = groupId;
      final group = _groups.firstWhere((g) => g['_id'] == groupId);
      _members = List<String>.from(group['memberUsernames']);
      _selectedMember = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>>(
          future: _fetchGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            _groups = snapshot.data ?? [];
            if (_groups.isNotEmpty && _selectedGroupId == null) {
              _selectedGroupId = _groups[0]['_id'];
              _members = List<String>.from(_groups[0]['memberUsernames']);
            }
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  if (_groups.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      items: _groups
                          .map<DropdownMenuItem<String>>(
                              (g) => DropdownMenuItem(
                                    value: g['_id'],
                                    child: Text(g['name']),
                                  ))
                          .toList(),
                      onChanged: _onGroupChanged,
                      decoration: const InputDecoration(labelText: 'Group'),
                      validator: (value) =>
                          value == null ? 'Select group' : null,
                    ),
                  if (_groups.isEmpty)
                    const Text('No groups found. Please create a group first.'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedMember,
                    items: _members
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedMember = val),
                    decoration: const InputDecoration(labelText: 'Paid By'),
                    validator: (value) =>
                        value == null ? 'Select member' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => _selectedDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration:
                        const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedGroupId == null || _selectedMember == null)
                          return;
                        await ExpenseService.addExpense(
                          groupId: _selectedGroupId!,
                          title: _titleController.text,
                          amount:
                              double.tryParse(_amountController.text) ?? 0.0,
                          paidBy: _selectedMember!,
                          date: _selectedDate,
                          notes: _notesController.text.isNotEmpty
                              ? _notesController.text
                              : null,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense Added!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Expense'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
