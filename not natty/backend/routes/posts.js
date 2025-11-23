const express = require('express');
const router = express.Router();

// Get posts
router.get('/', (req, res) => {
  res.json({ message: 'Get posts endpoint' });
});

// Create post
router.post('/', (req, res) => {
  res.json({ message: 'Create post endpoint' });
});

// Like post
router.post('/:id/like', (req, res) => {
  res.json({ message: 'Like post endpoint' });
});

module.exports = router; 