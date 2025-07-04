import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  username: { type: String, unique: true, required: true },
  email:    { type: String, unique: true, required: true },
  password: { type: String, required: true },
  groupIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Group' }]
});

export default mongoose.model('User', userSchema); 