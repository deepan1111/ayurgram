import { Router } from 'express';
import auth from '../middleware/auth.middleware.js';
import { requireRole } from '../middleware/role.middleware.js';
import { createCollection, listMyCollections, listAllCollections, getCollectionById } from '../controllers/collection.controller.js';

const router = Router();

router.use(auth);
router.post('/', createCollection);
router.get('/', listMyCollections);
// Admin/lab visibility for all collections
router.get('/all', requireRole('admin', 'lab'), listAllCollections);
router.get('/:id', requireRole('admin', 'lab'), getCollectionById);

export default router;
