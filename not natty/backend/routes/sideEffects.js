const express = require('express');
const router = express.Router();

// Get side effects
router.get('/', (req, res) => {
  res.json({ message: 'Get side effects endpoint' });
});

// Create side effect
router.post('/', (req, res) => {
  res.json({ message: 'Create side effect endpoint' });
});

module.exports = router; 