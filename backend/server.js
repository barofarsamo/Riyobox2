const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();
const app = express();
app.use(express.json());

// Enable CORS for all origins
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use('/auth', require('./routes/auth'));
app.use('/admin', require('./routes/admin'));
app.use('/movies', require('./routes/movies'));
app.use('/users', require('./routes/users'));
app.use('/upload', require('./routes/upload'));

app.get('/', (req, res) => res.json({
  message: 'Riyobox API is running...',
  database: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected',
  timestamp: new Date().toISOString()
}));

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/riyobox';

const createDefaultAdmin = async () => {
  try {
    const adminEmail = 'admin@example.com';
    const adminExists = await User.findOne({ email: adminEmail });

    if (!adminExists) {
      console.log('Creating default admin account...');
      const admin = await User.create({
        name: 'Super Admin',
        email: adminEmail,
        password: 'admin123',
        role: 'admin'
      });
      console.log('✅ Default admin created successfully:', admin.email);
    } else {
      console.log('ℹ️ Admin account already exists:', adminExists.email);
    }
  } catch (error) {
    console.error('❌ Error creating default admin:', error.message);
    if (error.code === 11000) {
      console.error('Email already exists (Race condition handled)');
    }
  }
};

mongoose.connect(MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected');
    await createDefaultAdmin();
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });
