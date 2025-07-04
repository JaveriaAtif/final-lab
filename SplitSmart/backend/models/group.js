import mongoose from 'mongoose';

const groupSchema = new mongoose.Schema({
  name: { type: String, required: true },
  memberUsernames: [String],
  adminUsername: String
});

export default mongoose.model('Group', groupSchema); 