import mongoose from 'mongoose';

const expenseSchema = new mongoose.Schema({
  groupId: { type: mongoose.Schema.Types.ObjectId, ref: 'Group', required: true },
  title: String,
  amount: Number,
  paidBy: String,
  date: Date,
  notes: String
});

export default mongoose.model('Expense', expenseSchema); 