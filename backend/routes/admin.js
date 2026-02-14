const express = require('express');
const Movie = require('../models/Movie');
const User = require('../models/User');
const { protect, adminOnly } = require('../middleware/authMiddleware');
const router = express.Router();

router.post('/movies', protect, adminOnly, async (req, res) => {
  const {
    title, description, posterUrl, backdropUrl,
    videoUrl, duration, year, genre,
    isTrending, contentRating
  } = req.body;

  try {
    const movie = new Movie({
      title, description, posterUrl, backdropUrl,
      videoUrl, duration, year, genre,
      isTrending, contentRating
    });
    const createdMovie = await movie.save();
    res.status(201).json(createdMovie);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/movies', protect, adminOnly, async (req, res) => {
  try {
    const movies = await Movie.find({});
    res.json(movies);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete('/movies/:id', protect, adminOnly, async (req, res) => {
  try {
    const movie = await Movie.findById(req.params.id);
    if (movie) {
      await movie.deleteOne();
      res.json({ message: 'Movie removed' });
    } else {
      res.status(404).json({ message: 'Movie not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/users', protect, adminOnly, async (req, res) => {
  try {
    const users = await User.find({}).select('-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
