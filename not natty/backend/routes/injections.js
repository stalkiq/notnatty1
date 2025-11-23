const express = require('express');
const router = express.Router();

// Get injections
router.get('/', (req, res) => {
  res.json({ message: 'Get injections endpoint' });
});

// Create injection
router.post('/', (req, res) => {
  res.json({ message: 'Create injection endpoint' });
});

module.exports = router; 