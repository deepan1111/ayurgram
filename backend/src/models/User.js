import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, index: true },
    hashedPassword: { type: String, required: true }, // keep naming aligned with Flutter model
    name: { type: String, required: true },
    role: { type: String, enum: ['collector', 'admin', 'user', 'lab'], default: 'user' },
  },
  { timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' } }
);

export default mongoose.model('User', userSchema);
