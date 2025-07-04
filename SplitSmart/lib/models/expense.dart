class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidBy;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.notes,
  });
}
