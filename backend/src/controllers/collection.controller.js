import Collection from '../models/Collection.js';

export async function createCollection(req, res) {
  try {
    const { species, quantityKg, notes, location, freshness, sizeScore, qualityNotes } = req.body;
    if (!species || quantityKg == null) {
      return res.status(400).json({ message: 'species and quantityKg are required' });
    }
    const doc = await Collection.create({
      collectorId: req.user.id,
      species,
      quantityKg,
      notes,
      location,
      freshness,
      sizeScore,
      qualityNotes,
    });
    return res.status(201).json({ collection: doc });
  } catch (err) {
    console.error('createCollection error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function listMyCollections(req, res) {
  try {
    const items = await Collection.find({ collectorId: req.user.id })
      .sort({ createdAt: -1 });
    return res.json({ collections: items });
  } catch (err) {
    console.error('listMyCollections error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function listAllCollections(req, res) {
  try {
    const { q } = req.query;
    let filter = {};
    if (q) {
      const ors = [ { species: { $regex: q, $options: 'i' } } ];
      // Full ObjectId match
      if (/^[a-fA-F0-9]{24}$/.test(q)) {
        try { ors.push({ _id: q }); } catch {}
      }
      // Short unique code (last 6 chars of ObjectId)
      if (q.length <= 12) {
        ors.push({ $expr: { $regexMatch: { input: { $toString: '$_id' }, regex: `${q}$`, options: 'i' } } });
      }
      filter = { $or: ors };
    }
    const items = await Collection.find(filter).sort({ createdAt: -1 });
    return res.json({ collections: items });
  } catch (err) {
    console.error('listAllCollections error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

export async function getCollectionById(req, res) {
  try {
    const doc = await Collection.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    return res.json({ collection: doc });
  } catch (err) {
    console.error('getCollectionById error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
}
