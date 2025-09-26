import auth from './auth.middleware.js';

export function requireRole(...roles) {
  return [
    auth,
    (req, res, next) => {
      const role = req.user?.role;
      if (!role || !roles.includes(role)) {
        return res.status(403).json({ message: 'Forbidden: insufficient role' });
      }
      next();
    }
  ];
}
