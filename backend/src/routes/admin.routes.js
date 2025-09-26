import { Router } from 'express';
import { requireRole } from '../middleware/role.middleware.js';
import { listUsers } from '../controllers/admin.controller.js';

const router = Router();

// Admin-only endpoints
router.get('/users', requireRole('admin'), listUsers);

export default router;
