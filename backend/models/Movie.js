const mongoose = require('mongoose');

const movieSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  posterUrl: { type: String, required: true },
  backdropUrl: { type: String },
  videoUrl: { type: String, required: true },
  duration: { type: String },
  year: { type: Number },
  genre: { type: [String] },
  rating: { type: Number, default: 0 },
  isTrending: { type: Boolean, default: false },
  contentRating: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Movie', movieSchema);
