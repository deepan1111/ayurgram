import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

function signToken(user) {
  const payload = { id: user._id, email: user.email, role: user.role, name: user.name };
  const secret = process.env.JWT_SECRET || 'dev_secret';
  const expiresIn = process.env.JWT_EXPIRES_IN || '7d';
  return jwt.sign(payload, secret, { expiresIn });
}

export async function register(req, res) {
  try {
    const { email, password, name, role, adminSecret, labSecret } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ message: 'email, password, and name are required' });
    }

    // Prevent arbitrary admin creation: require a valid admin secret for admin signups
    if (role === 'admin') {
      const expected = (process.env.ADMIN_SIGNUP_SECRET || '').trim();
      const provided = (adminSecret || '').trim();
      if (!expected || provided !== expected) {
        return res.status(403).json({ message: 'Forbidden: invalid admin signup credentials' });
      }
    }

    // Prevent arbitrary lab creation: require a valid lab secret for lab signups
    if (role === 'lab') {
      const expectedLab = (process.env.LAB_SIGNUP_SECRET || '').trim();
      const providedLab = (labSecret || '').trim();
      if (!expectedLab || providedLab !== expectedLab) {
        return res.status(403).json({ message: 'Forbidden: invalid lab signup credentials' });
      }
    }

    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(409).json({ message: 'User with this email already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({ email, hashedPassword, name, role: role || 'user' });

    const token = signToken(user);
    return res.status(201).json({
      user: { _id: user._id, id: user._id, email: user.email, name: user.name, role: user.role, createdAt: user.createdAt },
      token,
    });
  } catch (err) {
    console.error('Register error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function login(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const valid = await bcrypt.compare(password, user.hashedPassword);
    if (!valid) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = signToken(user);
    return res.json({
      user: { _id: user._id, id: user._id, email: user.email, name: user.name, role: user.role, createdAt: user.createdAt },
      token,
    });
  } catch (err) {
    console.error('Login error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function me(req, res) {
  try {
    const user = await User.findById(req.user.id).select('-hashedPassword');
    return res.json({ user });
  } catch (err) {
    console.error('Me error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}
