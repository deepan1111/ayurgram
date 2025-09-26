import User from '../models/User.js';

export async function listUsers(req, res) {
  try {
    const { q } = req.query;
    const filter = q
      ? {
          $or: [
            { _id: q },
            { email: { $regex: q, $options: 'i' } },
            { name: { $regex: q, $options: 'i' } },
          ],
        }
      : {};
    const users = await User.find(filter).select('-hashedPassword').sort({ createdAt: -1 });
    return res.json({ users });
  } catch (err) {
    console.error('listUsers error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}
