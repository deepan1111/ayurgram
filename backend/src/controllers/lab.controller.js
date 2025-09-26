import mongoose from 'mongoose';
import LabRecord from '../models/LabRecord.js';

export async function createLabRecord(req, res) {
  try {
    let { batchId, collectionId, technicianId, testDate, status, notes, moisture, ashContent, pesticideLevel, microbialLoad, activeCompounds, report } = req.body;
    // default technicianId to the authenticated user's id if not provided
    if (!technicianId && req.user?.id) technicianId = req.user.id;
    if (testDate) testDate = new Date(testDate);
    // Validate collectionId if present
    if (collectionId != null && collectionId !== '') {
      if (!mongoose.Types.ObjectId.isValid(collectionId)) {
        return res.status(400).json({ message: 'Invalid collectionId. Expecting a 24-char hex ObjectId.' });
      }
    } else {
      collectionId = undefined;
    }
    const doc = await LabRecord.create({ batchId, collectionId, technicianId, testDate, status, notes, moisture, ashContent, pesticideLevel, microbialLoad, activeCompounds, report });
    return res.status(201).json({ record: doc });
  } catch (err) {
    console.error('createLabRecord error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function listLabRecords(req, res) {
  try {
    const { q } = req.query;
    let filter = {};
    if (q) {
      const ors = [ { batchId: q } ];
      // Full ObjectId match if q is 24-hex
      if (/^[a-fA-F0-9]{24}$/.test(q)) {
        ors.push({ _id: new mongoose.Types.ObjectId(q) });
      }
      // Short unique code (last 6 chars of ObjectId)
      if (q.length <= 12) {
        ors.push({ $expr: { $regexMatch: { input: { $toString: '$_id' }, regex: `${q}$`, options: 'i' } } });
      }
      filter = { $or: ors };
    }
    const items = await LabRecord.find(filter).sort({ createdAt: -1 });
    return res.json({ records: items });
  } catch (err) {
    console.error('listLabRecords error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function getLabRecord(req, res) {
  try {
    const doc = await LabRecord.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    return res.json({ record: doc });
  } catch (err) {
    console.error('getLabRecord error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function listMyLabRecords(req, res) {
  try {
    // For simplicity, store technicianId as the authenticated user's id
    const techId = req.user?.id;
    if (!techId) return res.status(401).json({ message: 'Unauthorized' });
    const { q } = req.query;
    const base = { technicianId: techId };
    let filter = base;
    if (q) {
      const ors = [ { batchId: q } ];
      if (/^[a-fA-F0-9]{24}$/.test(q)) {
        ors.push({ _id: new mongoose.Types.ObjectId(q) });
      }
      if (q.length <= 12) {
        ors.push({ $expr: { $regexMatch: { input: { $toString: '$_id' }, regex: `${q}$`, options: 'i' } } });
      }
      filter = { ...base, $or: ors };
    }
    const items = await LabRecord.find(filter).sort({ createdAt: -1 });
    return res.json({ records: items });
  } catch (err) {
    console.error('listMyLabRecords error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function updateLabRecord(req, res) {
  try {
    const id = req.params.id;
    const update = req.body || {};
    const doc = await LabRecord.findByIdAndUpdate(id, update, { new: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });
    return res.json({ record: doc });
  } catch (err) {
    console.error('updateLabRecord error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}
