const express = require('express');
const router = express.Router();

// Get cycles
router.get('/', (req, res) => {
  res.json({ message: 'Get cycles endpoint' });
});

// Create cycle
router.post('/', (req, res) => {
  res.json({ message: 'Create cycle endpoint' });
});

module.exports = router; 