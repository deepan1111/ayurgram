import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import authRoutes from './src/routes/auth.routes.js';
import collectionRoutes from './src/routes/collection.routes.js';
import path from 'path';
import { fileURLToPath } from 'url';
import labRoutes from './src/routes/lab.routes.js';
import adminRoutes from './src/routes/admin.routes.js';

// Ensure .env is loaded from the same directory as this file (Windows-safe)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.join(__dirname, '.env') });

const app = express();
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || '';

// Middlewares
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());
app.use(morgan('dev'));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/collections', collectionRoutes);
app.use('/api/lab', labRoutes);
app.use('/api/admin', adminRoutes);

async function start() {
  try {
    if (!MONGO_URI) {
      console.error('Missing MONGO_URI in environment');
      process.exit(1);
    }

    await mongoose.connect(MONGO_URI, {
      dbName: process.env.DB_NAME || 'ayurtrack',
    });
    console.log('Connected to MongoDB');

    app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
