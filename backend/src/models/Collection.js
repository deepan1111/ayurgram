import mongoose from 'mongoose';

const collectionSchema = new mongoose.Schema(
  {
    collectorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    species: { type: String, required: true },
    quantityKg: { type: Number, required: true, min: 0 },
    notes: { type: String },
    location: {
      lat: { type: Number },
      lng: { type: Number },
    },
    // Quality assessment
    freshness: { type: Number, min: 0, max: 10 },
    sizeScore: { type: Number, min: 0, max: 10 },
    qualityNotes: { type: String },
  },
  { timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' } }
);

export default mongoose.model('Collection', collectionSchema);
