const express = require('express');
const User = require('../models/User');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

// Get user profile including watchlist
router.get('/profile', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('watchlist');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Toggle movie in watchlist
router.post('/watchlist/:movieId', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const movieId = req.params.movieId;

    const index = user.watchlist.indexOf(movieId);
    if (index > -1) {
      user.watchlist.splice(index, 1);
      await user.save();
      res.json({ message: 'Removed from watchlist', isAdded: false });
    } else {
      user.watchlist.push(movieId);
      await user.save();
      res.json({ message: 'Added to watchlist', isAdded: true });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
