import { Router } from 'express';
import { requireRole } from '../middleware/role.middleware.js';
import { createLabRecord, listLabRecords, getLabRecord, listMyLabRecords, updateLabRecord } from '../controllers/lab.controller.js';

const router = Router();

// Admin can list; lab and admin can read/create
router.get('/', requireRole('admin'), listLabRecords);
router.get('/mine', requireRole('lab', 'admin'), listMyLabRecords);
router.get('/:id', requireRole('lab', 'admin'), getLabRecord);
router.post('/', requireRole('lab', 'admin'), createLabRecord);
router.put('/:id', requireRole('lab', 'admin'), updateLabRecord);

export default router;
