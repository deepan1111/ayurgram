import mongoose from 'mongoose';

const labRecordSchema = new mongoose.Schema(
  {
    batchId: { type: String, index: true },
    collectionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Collection' },
    technicianId: { type: String },
    testDate: { type: Date },
    status: { type: String, enum: ['pending', 'pass', 'fail'], default: 'pending' },
    notes: { type: String },
    // example params (extend as needed)
    moisture: { type: String },
    ashContent: { type: String },
    pesticideLevel: { type: String },
    microbialLoad: { type: String },
    activeCompounds: { type: String },
    // consolidated report text entered by lab processor
    report: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model('LabRecord', labRecordSchema);
