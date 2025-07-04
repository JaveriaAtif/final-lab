import express from 'express';
import Expense from '../models/expense.js';

const router = express.Router();

// Add expense
router.post('/add', async (req, res) => {
  const { groupId, title, amount, paidBy, date, notes } = req.body;
  const expense = new Expense({ groupId, title, amount, paidBy, date, notes });
  await expense.save();
  res.status(201).json(expense);
});

// List expenses for group
router.get('/group/:groupId', async (req, res) => {
  const expenses = await Expense.find({ groupId: req.params.groupId });
  res.json(expenses);
});

// Edit expense
router.put('/:id', async (req, res) => {
  const updates = req.body;
  const expense = await Expense.findByIdAndUpdate(req.params.id, updates, { new: true });
  res.json(expense);
});

// Delete expense
router.delete('/:id', async (req, res) => {
  await Expense.findByIdAndDelete(req.params.id);
  res.json({ message: 'Expense deleted' });
});

export default router; 