import express from 'express';
import Group from '../models/group.js';
import User from '../models/user.js';

const router = express.Router();

// Create group
router.post('/create', async (req, res) => {
  const { name, adminUsername } = req.body;
  const group = new Group({ name, memberUsernames: [adminUsername], adminUsername });
  await group.save();
  const user = await User.findOne({ username: adminUsername });
  user.groupIds.push(group._id);
  await user.save();
  res.status(201).json(group);
});

// List groups for user
router.get('/user/:username', async (req, res) => {
  const groups = await Group.find({ memberUsernames: req.params.username });
  res.json(groups);
});

// Invite user
router.post('/invite', async (req, res) => {
  const { groupId, username } = req.body;
  const group = await Group.findById(groupId);
  if (!group.memberUsernames.includes(username)) {
    group.memberUsernames.push(username);
    await group.save();
    const user = await User.findOne({ username });
    if (user) {
      user.groupIds.push(group._id);
      await user.save();
    }
    return res.json({ message: 'User invited' });
  }
  res.status(400).json({ error: 'User already in group' });
});

export default router; 