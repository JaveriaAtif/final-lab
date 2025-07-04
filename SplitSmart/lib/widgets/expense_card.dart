import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final double amount;
  final String paidBy;

  const ExpenseCard(
      {Key? key,
      required this.title,
      required this.amount,
      required this.paidBy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('Paid by: $paidBy'),
        trailing: Text('Rs. $amount'),
      ),
    );
  }
}
