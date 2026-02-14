const express = require('express');
const mongoose = require('mongoose');
const Movie = require('../models/Movie');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

router.get('/', protect, async (req, res) => {
  try {
    const { genre, isTrending } = req.query;
    let query = {};
    if (genre) query.genre = genre;
    if (isTrending) query.isTrending = isTrending === 'true';

    const movies = await Movie.find(query);
    res.json(movies);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/:id', protect, async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid movie ID' });
    }
    const movie = await Movie.findById(req.params.id);
    if (movie) {
      res.json(movie);
    } else {
      res.status(404).json({ message: 'Movie not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
